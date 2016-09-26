require 'ruby_box/version'

module RubyBox
  autoload :Bindings, 'ruby_box/bindings'
  autoload :BoxedError, 'ruby_box/boxed_error'
  autoload :Bridging, 'ruby_box/bridging'
  autoload :CompilationError, 'ruby_box/compilation_error'
  autoload :Error, 'ruby_box/error'
  autoload :Execution, 'ruby_box/execution'
  autoload :ExecutionError, 'ruby_box/execution_error'
  autoload :Metal, 'ruby_box/metal'
  autoload :RuntimeEnvironment, 'ruby_box/runtime_environment'
  autoload :ThreadSafety, 'ruby_box/thread_safety'
  autoload :TimeoutError, 'ruby_box/timeout_error'

  extend self

  def self.boxed?
    false
  end

  def self.current
    nil
  end

  def execute(*args, &block)
    Metal.execute(*args, &block)
  end
end
