require 'ruby_box'

module RubyBox
  module Bindings
    extend ActiveSupport::Concern

    class_methods do
      def bindings
        @bindings ||= begin
          if superclass.respond_to?(:bindings)
            superclass.bindings.dup
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

    private

    def bind(target, proc = Proc.new)
       context.attach(target, proc)
    end
  end
end
