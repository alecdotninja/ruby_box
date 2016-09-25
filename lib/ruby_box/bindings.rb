require 'ruby_box'

module RubyBox
  module Bindings
    extend ActiveSupport::Concern

    class_methods do
      def bindings
        @bindings ||= begin
          if defined?(super)
            super.dup
          else
            []
          end
        end
      end

      private

      def binds(target, proc = Proc.new)
        bindings << [target, proc]
      end
    end

    def initialize(*)
      super

      self.class.bindings.each do |target, proc|
        bind target, proc { |*args| instance_exec(*args, &proc) }
      end
    end

    def bind(target, proc = Proc.new)
       context.attach(target, proc)
    end
  end
end
