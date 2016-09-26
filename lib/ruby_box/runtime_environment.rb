require 'ruby_box'

require 'active_support/concern'
require 'opal'

module RubyBox
  module RuntimeEnvironment
    extend ActiveSupport::Concern

    included do
      requires 'opal'
      requires 'opal-parser'
    end

    class_methods do
      def builder
        @builder ||= begin
          if superclass.respond_to?(:builder)
            superclass.builder.dup
          else
            Opal::Builder.new compiler_options: { arity_check: true, dynamic_require_severity: :error }
          end
        end
      end

      private

      def uses(*gem_names)
        gem_names.each { |gem_name| builder.use_gem gem_name }
      rescue SyntaxError => error
        raise CompilationError, error.message
      end

      def requires(*paths)
        paths.each { |path| builder.build path }
      rescue SyntaxError => error
        raise CompilationError, error.message
      end

      def executes(source)
        builder.build_str source, '(executes)'
      rescue SyntaxError => error
        raise CompilationError, error.message
      end

      def snapshot_source
        builder.to_s
      end
    end

    def builder
      @builder ||= self.class.builder.dup
    end

    def use(gem_name)
      execute_newly_processed_dependencies { builder.use_gem gem_name }
    rescue SyntaxError => error
      raise CompilationError, error.message
    end

    def require(path)
      execute_newly_processed_dependencies { builder.build path }
    rescue SyntaxError => error
      raise CompilationError, error.message
    end

    def execute(source)
      execute_newly_processed_dependencies { builder.build_str source, '(execute)' }
    rescue SyntaxError => error
      raise CompilationError, error.message
    end

    private

    def execute_newly_processed_dependencies
      value = nil
      capture_newly_processed_dependencies { yield }.each { |dependency| value = eval_compiled_source dependency.source }
      value
    end

    def capture_newly_processed_dependencies
      processed_was = builder.processed.dup
      yield
      builder.processed - processed_was
    end
  end
end