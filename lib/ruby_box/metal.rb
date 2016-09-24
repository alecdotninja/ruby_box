require 'ruby_box'

module RubyBox
  class Metal
    extend MonitorMixin

    DEFAULT_TIMEOUT_SECONDS = 1

    class << self
      def execute(*args, &block)
        new.execute(*args, &block)
      end

      def timeout
        synchronize { @timeout ||= build_timeout }
      end

      def builder
        synchronize { @builder ||= build_builder }
      end

      def snapshot
        synchronize { @snapshot ||= build_snapshot }
      end

      def clear_snapshot
        synchronize { @snapshot = nil }
      end

      def definitions
        synchronize { @defines ||= build_definitions }
      end

      private

      def times_out_in(seconds)
        @timeout = seconds
      end

      def uses(*gem_names)
        gem_names.each { |gem_name| builder.use_gem gem_name }
      end

      def requires(*paths)
        paths.each { |path| builder.build path }
      end

      def executes(source)
        builder.build_str source, '(executes)'
      end

      def defines(target, proc = Proc.new)
        synchronize { definitions << [target, proc] }
      end

      def build_timeout
        if defined?(super)
          super
        else
          DEFAULT_TIMEOUT_SECONDS
        end
      end

      def build_builder
        if defined?(super)
          super.dup
        else
          Opal::Builder.new compiler_options: { arity_check: true, dynamic_require_severity: :error }
        end
      end

      def build_snapshot
        MiniRacer::Snapshot.new builder.to_s
      end

      def build_definitions
        if defined?(super)
          super.dup
        else
          []
        end
      end
    end

    include MonitorMixin

    requires 'opal'
    requires 'opal-parser'

    defines('Opal.exit') { |status| raise Error, "Exit with status #{status.inspect}" }
    defines('Opal.STDOUT.write_proc') { |data| stdout << data }
    defines('Opal.STDERR.write_proc') { |data| stderr << data }

    def timeout
      synchronize { @timeout ||= self.class.timeout }
    end

    def builder
      synchronize { @builder ||= build_builder }
    end

    def use(gem_name)
      execute_newly_processed { builder.use_gem gem_name }
    end

    def require(path)
      execute_newly_processed { builder.build path }
    end

    def execute(source)
      execute_newly_processed { builder.build_str source, '(execute)' }
    end

    def define(target, proc = Proc.new)
      synchronize { context.attach(target, proc) }
    end

    def stdout
      synchronize { @stdout ||= [] }
    end

    def stderr
      synchronize { @stderr ||= [] }
    end

    private

    def execute_newly_processed
      value = nil
      capture_newly_processed { yield }.each { |processed| value = eval_source processed.source }
      value
    end

    def capture_newly_processed
      synchronize do
        processed_was = builder.processed.dup
        yield
        builder.processed - processed_was
      end
    end

    def context
      synchronize { @context ||= build_context }
    end

    def timeout_ms
      timeout * 1000 if timeout
    end

    def build_builder
      self.class.builder.dup
    end

    def build_context
      MiniRacer::Context.new(snapshot: self.class.snapshot, timeout: timeout_ms).tap do |context|
        self.class.definitions.each do |target, proc|
          context.attach(target, proc { |*args| instance_exec(*args, &proc) })
        end
      end
    end

    def eval_source source
      context.eval source
    rescue MiniRacer::RuntimeError => error
      raise Error, error.message
    end
  end
end