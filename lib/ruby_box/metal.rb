require 'ruby_box'

module RubyBox
  class Metal
    include Execution
    include RuntimeEnvironment
    include Bindings
    include Bridging
    include ThreadSafety

    def self.execute(*args, &block)
      new.execute(*args, &block)
    end
  end
end