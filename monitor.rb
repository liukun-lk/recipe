require 'thread'
# jruby 9.1.7.0 (2.3.1)
# 1. ------inherit Mutex-------
# class Counter < Mutex
#   attr_reader :number
#   def initialize
#     @number = 0
#     super
#   end

#   def plus
#     synchronize do
#       @number += 1
#     end
#   end
# end
# 2. ------include Monitor------
# class Counter
#   include MonitorMixin
#   attr_reader :number
#   def initialize
#     @number = 0
#     super
#   end

#   def plus
#     synchronize do
#       @number += 1
#     end
#   end
# end
# 3. ------error example------
# class Counter
#   attr_reader :number
#   def initialize
#     @number = 0
#   end

#   def plus
#     @number += 1
#   end
# end
# 4. ------use Mutex------
# class Counter
#   attr_reader :number
#   def initialize
#     @number = 0
#     @mutex = Mutex.new
#   end

#   def plus
#     @mutex.synchronize do
#       @number += 1
#     end
#   end
# end
# 5. -------------------
class Counter
  attr_reader :number, :q
  def initialize
    @number = 0
    @q = Queue.new
  end

  def start
    (1..20_000).each do
      @q.push(1)
    end
  end

  def plus
    while line = q.pop
      @number += 1
      p @number
    end
  end
end


# c = Counter.new
# t1 = Thread.new { 10_000.times { c.plus } }
# t2 = Thread.new { 10_000.times { c.plus } }
# t1.join
# t2.join
c = Counter.new
c.start
t1 = Thread.new { 10_000.times { c.plus } }
t2 = Thread.new { 10_000.times { c.plus } }
t1.join
t2.join
puts c.number

# q = Queue.new

# (1..10).each do
#   Thread.new {
#     while line = q.pop
#       print "#{Thread.current} #{line}"
#     end
#   }
# end

# while (u = gets)
#   q.push(u)
# end