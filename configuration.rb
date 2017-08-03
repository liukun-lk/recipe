module YourProjectNamespace
  class Configuration
    attr_accessor :you_want_to_init

    def initialize
      @you_want_to_init = ""
    end
  end

  def self.configure
    yield configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configuration=(configuration)
    @configuration = configuration
  end
end

# YourProjectNamespace.configure do |config|
#   config.you_want_to_init = 'you can config a new value'
# end
# ===========
# And you can use meta-programming for Configurable
# class SomeClass
#   include Configurable.with(:foo, :bar)
# end

# SomeClass.configure do |config|
#   config.foo = "wat"
#   config.bar = "huh"
# end

# SomeClass.config.foo
# => "wat"

module Configurable
  def self.with(*attrs)
    # Define anonymous class with the configuration attributes
    config_class = Class.new do
      attr_accessor *attrs
    end

    # Define anonymous module for the class methods to be "mixed in"
    class_methods = Module.new do
      define_method :config do
        @config ||= config_class.new
      end

      def configure
        yield config
      end
    end

    # Create and return new module
    Module.new do
      singleton_class.send :define_method, :included do |host_class|
        host_class.extend class_methods
      end
    end
  end
end
