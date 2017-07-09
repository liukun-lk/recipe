# 最近换了新机，在搭建环境的时候准备运行 rake db:migrate 的时候抛异常了，具体的内容可以看 error_messages.md，
# 从调用栈中可以看到这么一段 spec/factories/games_tags.rb:5:in `block (2 levels) in <top (required)>'
# 然而奇怪的是下一段就跳到 lib/tasks/cache.rake:17:in `tag_term'，似乎是该 rake 任务中的某个方法出来问题。
# 当然该 rake 中的代码片段是直接调用到了 model 层，然而此时连数据库迁移都没跑，model 对象肯定也是没有的。
# 那么问题就来了：1. 为什么跑 rake 命令的时候会先去跑 factory girl ？2. 即使是先去跑 factory girl，那为什么会调用到 rake 代码里面的方法？
#
# 这里漏说了一点，factory girl 中的代码里调用了 tag_term 这个方法，但是这里是为了创建关联关系而已。
# 后来去 Google 上面寻找了一下，果然有相关的问题提出来，
# https://stackoverflow.com/questions/7180732/method-namespace-clashing-when-running-rake-tasks-in-rails
# 里面说到在写 rake 相关的文件时，如果在 namespace 里面定义了方法，该方法会被共享到全局作用域中。因此 factory girl 调用到 rake 里面也好解释了。

# 相应的解决办法是：
# 1. 将方法定义放到 task 内部。
# 2. 如果想要复用方法的话，就在 rake 文件内部定义一个 Module 然后 include 到 task 内部就行。
# lib/tasks/a.rake:
module HelperMethodsA
  def msg(msg)
    puts "MSG SENT FROM Task A: #{msg}"
  end
end

namespace :a do
  desc "Task A"
  task(:a => :environment) do
    include HelperMethodsA
    msg('I AM TASK A')
  end
end

# lib/tasks/b.rake:
module HelperMethodsB
  def msg(msg)
    puts "MSG SENT FROM Task B: #{msg}"
  end
end

namespace :b do
  desc "Task B"
  task(:b => :environment) do
    include HelperMethodsB
    msg('I AM TASK B')
  end
end
