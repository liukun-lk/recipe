class Resource
  # Manual (dangerous) interface.
  def initialize
    # 来创建并返回我们需要保护的资源，类似运行的进程建立的数据库连接或者是句柄。
    @resource = allocate_resource
    finalizer = self.class.finalizer(@resource)
    # 通知垃圾收集器 GC，当第一个参数被销毁后，它会在第二个参数里调用 Proc 对象。
    ObjectSpace.define_finalizer(self, finalizer)
  end

  def close
    ObjectSpace.undefine_finalizer(self)
    @resource.close
  end

  # Return a Proc which can be used to free a resource.
  def self.finalizer(resource)
    lambda { |id| resource.close }
  end
end

# false
def initialize
  @resource = allocate_resource

  # DON'T DO THIS!!
  finalizer = lambda { |id| @resource.close }
  # 定义当 Resource 被清除时调用 finalizer 去清除 @resource 资源
  # 但是 finalizer 内部绑定了 Resource 对象，也就是 self。
  # 因此 Resource 是不会被垃圾收集器清除的，因为该对象能够被再次访问。
  # 这就发生了 Resource 不会被清除，而 finalizer 不会被调用到。
  ObjectSpace.define_finalizer(self, finalizer)
end
# 创建 Proc 对象的同时也创建了一个闭包，换句话说，创建了一个绑定
# 在这个绑定中，所以在 Proc 对象创建的时候存在的局部变量在 Proc 对象内都是可用的。
# 重要的是：这个闭包还会获取 self 变量。
# 如果 finalizer 以这样的方式保持住 Resource 对象，那么垃圾收集器就会一直将它视为可访问并永不被清除。
