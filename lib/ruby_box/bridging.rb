require 'ruby_box'

require 'json'
require 'active_support/concern'

module RubyBox
  module Bridging
    extend ActiveSupport::Concern

    included do
      requires 'json'

      binds('Opal.exit') { |status| raise Error, "Exit with status #{status.inspect}" }

      binds('Opal.STDOUT.write_proc') { |data| stdout << data }
      binds('Opal.STDERR.write_proc') { |data| stderr << data }

      executes <<-RUBY
        module RubyBox
          VERSION = #{VERSION.inspect}

          def self.boxed?
            true
          end
        end
      RUBY
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

      value = JSON.parse(serialized_value)

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