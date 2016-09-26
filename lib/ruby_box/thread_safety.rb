require 'ruby_box'

require 'active_support/concern'
require 'thread'
require 'monitor'

module RubyBox
  module ThreadSafety
    extend ActiveSupport::Concern

    SEMAPHORE = Mutex.new

    class_methods do
      def maximum_execution_time
        synchronize { super }
      end

      def builder
        synchronize { super }
      end

      def snapshot
        synchronize { super }
      end

      def bindings
        synchronize { super }
      end

      private

      def times_out_in(*)
        synchronize { super }
      end

      def uses(*)
        synchronize { super }
      end

      def requires(*)
        synchronize { super }
      end

      def executes(*)
        synchronize { super }
      end

      def binds(*)
        synchronize { super }
      end

      def exposes(*)
        synchronize { super }
      end

      def synchronize
        monitor.synchronize { yield }
      end

      def monitor
        SEMAPHORE.synchronize { @monitor ||= Monitor.new }
      end
    end

    def maximum_execution_time
      synchronize { super }
    end

    def builder
      synchronize { super }
    end

    def execute(*)
      synchronize { super }
    end

    def stdout
      synchronize { super }
    end

    def stderr
      synchronize { super }
    end

    private

    def synchronize
      monitor.synchronize { yield }
    end

    def monitor
      SEMAPHORE.synchronize { @monitor ||= Monitor.new }
    end
  end
end


