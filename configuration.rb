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
