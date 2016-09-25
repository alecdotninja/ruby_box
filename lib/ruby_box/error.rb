require 'ruby_box'

module RubyBox
  class Error < StandardError
    def self.[](class_name)
      boxed_class_name = :"Boxed#{class_name}"

      if const_defined?(boxed_class_name) && (klass = const_get(boxed_class_name)) < BoxedError
        klass
      else
        const_set(boxed_class_name, Class.new(self))
      end
    end
  end
end