## Rails 中的事务处理

> 本文主要介绍一下 Rails 中事务的使用方法。

### 隔离性（isolation）：
- `脏读`：事务A修改了一个数据，但未提交，事务 B 读到了事务 A 未提交的更新结果，如果事务 A 提交失败，事务 B 读到的就是脏数据。
- `不可重复读`：在同一个事务中，对于同一份数据读取到的结果不一致。比如，事务 B 在事务A提交前读到的结果，和提交后读到的结果可能不同。不可重复读出现的原因就是事务并发修改记录，要避免这种情况，最简单的方法就是对要修改的记录加锁，这回导致锁竞争加剧，影响性能。另一种方法是通过 MVCC 可以在无锁的情况下，避免不可重复读。
- `幻读`：在同一个事务中，同一个查询多次返回的结果不一致。事务 A 新增了一条记录，事务 B 在事务 A 提交前后各执行了一次查询操作，发现后一次比前一次多了一条记录。幻读是由于并发事务增加记录导致的，这个不能像不可重复读通过记录加锁解决，因为对于新增的记录根本无法加锁。需要将事务串行化，才能避免幻读。

>作者：郭无心
>链接：https://www.zhihu.com/question/31346392/answer/59815366
>来源：知乎
>著作权归作者所有。商业转载请联系作者获得授权，非商业转载请注明出处。

为了避免以上问题，Rails 的 `ActiveRecord::ConnectionAdapters::DatabaseStatements#transaction` 方法允许传入三个参数`requires_new: nil, isolation: nil, joinable: true`，其中 isolation 是来设置事务的隔离性的。isolation 的等级有如下四种：
- :read_uncommitted: 未提交读，读脏数据
- :read_committed:
- :repeatable_read: 避免不可重复读
- :serializable: 避免幻读

> read_committed: 读操作之前首先申请并获得共享锁，允许其他读操作读取该锁定的数据，但是写操作必须等待锁释放，一般读操作读取完就会立刻释放共享锁。**注意**：但是由于READ COMMITTED读操作一完成就立即释放共享锁，读操作不会在一个事务过程中保持共享锁，也就是说在一个事务的的两个查询过程之间有另一个回话对数据资源进行了更改，会导致一个事务的两次查询得到的结果不一致,这种现象称之为不可重复读。

```ruby
ActiveRecord::Schema.define do
  create_table :orders, force: true do |t|
    t.integer :stock, default: 0
  end
end

class Order < ActiveRecord::Base
end

order = Order.create!(stock: 100)

t1 = Thread.new do
  Order.transaction isolation: :read_committed do
    x = Order.find 1
    puts "1. #{x.stock}" #=> 1. 100
    sleep 2
    x = Order.find 1
    puts "2. #{x.stock}" #=> 2. 104
  end
end
t2 = Thread.new do
  Order.transaction do
    x = Order.find 1
    x.stock += 4
    x.save!
  end
end
t1.join
t2.join
```

> repeatable_read: 保证在一个事务中的两个读操作之间，其他的事务不能修改当前事务读取的数据，该级别事务获取数据前必须先获得共享锁同时获得的共享锁不立即释放一直保持共享锁至事务完成。
```ruby
ActiveRecord::Schema.define do
  create_table :orders, force: true do |t|
    t.integer :stock, default: 0
  end
end

class Order < ActiveRecord::Base
end

order = Order.create!(stock: 100)

t1 = Thread.new do
  Order.transaction isolation: :repeatable_read do
    x = Order.find 1
    puts "1. #{x.stock}" #=> 1. 104 | 1. 100 要看 t2 先于 t1 的第一次 find 还是后于。先于是 104，后于是 100。
    sleep 2
    x = Order.find 1
    puts "2. #{x.stock}" #=> 2. 104 | 2. 100
  end
end
t2 = Thread.new do
  Order.transaction do
    x = Order.find 1
    x.stock += 4
    x.save!
  end
end
t1.join
t2.join
```

repeatable_read 只能保证在当前事务下（同一事务里面）用户进行多次读同一数据库表的时候读出来的数据是相同的，不会因为两个查询过程之间有另一个会话对数据资源进行了更改，而导致两次查询的数据不一致。而且对于数据的修改操作，最好的做法是使用 `update_counters `，这样数据库帮你做了原子性更新。

> **注意**：在可重复读(Repeatable Read)事务隔离级别，可以完全防止更新丢失(覆盖)的问题,如果当前事务读取了某行，这期间其他并发事务修改了这一行并提交了，然后当前事务试图更新该行时，PostgreSQL 会提示: ERROR: could not serialize access due to concurrent update 事务会被回滚，只能重新开始。但是当数据库为 MySQL 时，即使是使用了 repeatable_read 的隔离条件，也不会出现上述的情况。

~~下表是根据日志算出来的，每次执行日志时间都是不同的：~~
|task|t1|t2|
|:--:|:--:|:--:|
|begin|1.8ms|0.6ms|
|update|+1.9ms|+1.2ms|
|commit|none|+1.2ms|

~~可以看到，t1 的 begin 时间正好落于 t2 的 update 和 commit 时间间隔内，也就是说在 [1.8ms, 3ms] 这个区间范围内，并发的事务 t1，不能对同一数据库表的同一行数据进行修改操作。不然就会报错。如果 t1 的执行时间稍微延迟至少`sleep >0.002 s`，那么两条 update 操作都能够执行了。~~

```ruby
t1 = Thread.new do
  Order.transaction isolation: :repeatable_read do
    sleep 1
    x = Order.update_counters 1, stock: 4
  end
end
t2 = Thread.new do
  Order.transaction isolation: :repeatable_read do
    x = Order.find 1 # 加上这句话之后 PostgreSQL 就会报 could not serialize access due to concurrent update 错误。
    sleep 2
    x = Order.find 1
    x.stock += 5
    x.save!
  end
end
t1.join
t2.join
```

目前就我理解是：看事务中是否使用到“快照读”。如果用到了，相当于第二次读出的数据在隔离性为 RR 级下会与第一次读出的数据相同。PostgreSQL 会直接拒绝修改数据。


----
> 针对MySQL来说，PG还未确定是否一致。

但即使是读，在 RR(Repeatable Read) 级别中，通过 MVCC 机制，虽然让数据变得可重复读，但我们读到的数据可能是历史数据，是不及时的数据，不是数据库当前的数据！这在一些对于数据的时效特别敏感的业务中，就很可能出问题。

对于这种读取历史数据的方式，我们叫它快照读 (snapshot read)，而读取数据库当前版本数据的方式，叫当前读 (current read)。很显然，在MVCC中：

- 快照读：就是select
	- select * from table ....;
- 当前读：特殊的读操作，插入/更新/删除操作，属于当前读，处理的都是当前的数据，需要加锁。
	- select * from table where ? lock in share mode;
	- select * from table where ? for update;
	- insert;
	- update ;
	- delete;

----

### 参考：
- [PostgreSQL防止更新丢失(覆盖)](http://openwares.net/database/postgresql_updata_lost.html)
- [Rails 中的事务处理](https://ruby-china.org/topics/25427)
- [《ActiveRecord Transaction 的疑问》下的评论](https://ruby-china.org/topics/17321)