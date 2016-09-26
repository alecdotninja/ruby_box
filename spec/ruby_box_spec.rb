require 'spec_helper'

describe RubyBox do
  it 'has a version number' do
    expect(RubyBox::VERSION).not_to be nil
  end

  it 'passes a basic sanity check' do
    expect(RubyBox.execute('1+1')).to eq(2)
  end

  it 'behaves like the README says' do
    class MySandbox < RubyBox::Metal
      # Code in the sandbox will block at most one second
      times_out_in 1#.second

      # Makes the opal gem available for requiring inside the sandbox
      uses 'opal'

      # Requires the Opal compiler inside the sandbox (enables advanced runtime meta-programming like `Kernel#eval`)
      requires 'opal-parser'

      # Exposes the #native_add method to code running inside the sandbox
      exposes :native_add

      # Executes some code in the sandbox to setup it's runtime state
      executes <<-RUBY
        # Some boilerplate code
        class PlayThing
          attr_reader :name

          def initialize(name)
            @name = name
          end

          # Code inside of the sandbox can get a handle on the box with `RubyBox.current` and call exposed methods
          def self.add(a, b)
            RubyBox.current.native_add(a, b)
          end
        end
      RUBY

      def native_add(a, b)
        a + b
      end
    end

    untrusted_program = <<-RUBY
      $global_state = 'tainted'

      puts "Hello, world"

      car = PlayThing.new("Car")
      car.name
    RUBY

    # Every instance of the sandbox starts with the state configured on the class
    my_sandbox = MySandbox.new
    expect(my_sandbox.execute(untrusted_program)).to eq 'Car'
    expect(my_sandbox.execute('PlayThing.add(2,7)')).to eq 9
    expect(my_sandbox.stdout).to eq(["Hello, world\n"])

    # Every instance of the sandbox is isolated
    another_sandbox = MySandbox.new
    expect(another_sandbox.execute('$global_state')).to be_nil

    # It also has an stderr
    another_sandbox.execute('warn "This looks dangerous"')
    expect(another_sandbox.stderr).to eq(["This looks dangerous\n"])

    # Exceptions comes through as subclasses of RubyBox::BoxedError
    expect { another_sandbox.execute('nil.no_method') }.to raise_error RubyBox::BoxedError

    # You can determine if you are in a sandbox using `RubyBox.boxed?` and `RubyBox.current`
    expect(RubyBox.boxed?).to be_falsey
    expect(RubyBox.current).to be_nil
  end
end
