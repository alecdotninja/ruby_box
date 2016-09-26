require 'ruby_box'

require 'json'
require 'active_support/concern'

module RubyBox
  module Bridging
    extend ActiveSupport::Concern

    included do
      requires 'native'
      requires 'singleton'
      requires 'json'

      binds('Opal.exit') { |status| raise Error, "Exit with status #{status.inspect}" }

      binds('Opal.STDOUT.write_proc') { |data| stdout << data }
      binds('Opal.STDERR.write_proc') { |data| stderr << data }

      executes <<-RUBY
        module RubyBox
          VERSION = #{VERSION.inspect}

          class CurrentBoxProxy
            include Singleton
          end

          def self.boxed?
            true
          end

          def self.current
            CurrentBoxProxy.instance
          end
        end
      RUBY
    end

    class_methods do
      def exposes(*method_names)
        method_names.each do |method_name|
          handle = "Opal.RubyBox.CurrentBoxProxy.__exposed_method_#{method_name}"

          wrapper = ->(serialized_args) do
            args = JSON.parse(serialized_args)
            value = send(method_name, *args)
            value.to_json
          end

          binds(handle, wrapper)

          executes <<-RUBY
            class RubyBox::CurrentBoxProxy
              define_method(#{method_name.inspect}) do |*args, &block|
                raise ArgumentError, 'Cannot pass block to bridged method `RubyBox::CurrentBoxProxy##{method_name}`' unless block.nil?

                serialized_args = args.to_json
                serialized_value = Native(`#{handle}`).call(serialized_args)

                JSON.parse(serialized_value, quirks_mode: true)
              end
            end
          RUBY
        end
      end
    end

    def stdout
      @stdout ||= []
    end

    def stderr
      @stderr ||= []
    end

    private

    def eval_compiled_source(source)
      is_caught_value, serialized_value = super(<<-JAVASCRIPT)
        (function(evaluator, source) {
          var isCaughtValue = false;
          var value;

          try{
            value = evaluator(source);

            if(value && typeof(value.$to_json) === 'function') {
              value = value.$to_json();
            }
          }catch(error){
            if(error && typeof(error.$class) === 'function' && typeof(error.$message) === 'function') {
              isCaughtValue = true;
              value = [error.$class().$name(), error.$message()];
            }else{
              throw error;
            }
          }

          if(typeof(value) !== 'string') {
            value = JSON.stringify(value);
          }

          return [isCaughtValue, value];
        })(eval, #{source.to_json});
      JAVASCRIPT

      value = JSON.parse(serialized_value, quirks_mode: true) if serialized_value

      if is_caught_value
        class_name, message = value
        raise BoxedError[class_name], message
      else
        value
      end
    rescue RuntimeError => error
      raise ExecutionError, error.message
    end
  end
end