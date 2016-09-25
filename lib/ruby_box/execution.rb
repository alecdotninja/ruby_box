require 'ruby_box'

require 'active_support/concern'
require 'mini_racer'

module RubyBox
  module Execution
    DEFAULT_MAXIMUM_EXECUTION_TIME_SECONDS = 1

    extend ActiveSupport::Concern

    class_methods do
      def maximum_execution_time
        @maximum_execution_time ||= begin
          if defined?(super)
            super
          else
            DEFAULT_MAXIMUM_EXECUTION_TIME_SECONDS
          end
        end
      end

      def snapshot
        @snapshot ||= begin
          MiniRacer::Snapshot.new snapshot_source
        end
      end

      private

      def snapshot_source
        ''
      end

      def times_out_in(seconds)
        @maximum_execution_time = seconds
      end
    end

    def maximum_execution_time
      @maximum_execution_time ||= self.class.maximum_execution_time
    end

    def maximum_execution_time_ms
      maximum_execution_time * 1000 if maximum_execution_time
    end

    private

    def context
      @context ||= MiniRacer::Context.new(snapshot: self.class.snapshot, timeout: maximum_execution_time_ms)
    end

    def eval_compiled_source(source)
      context.eval source
    rescue MiniRacer::RuntimeError => error
      raise RuntimeError, error.message
    rescue MiniRacer::ScriptTerminatedError => error
      raise TimeoutError, error.message
    end
  end
end