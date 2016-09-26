# RubyBox

RubyBox allows the execution of untrusted Ruby code safely in a sandbox. It works by compiling Ruby code to JavaScript using [`opal`](https://github.com/opal/opal) and executing in [Google's V8 Engine](https://github.com/cowboyd/libv8) with some help from [`mini_racer`](https://github.com/discourse/mini_racer/tree/6fbec25677d1fb14f8a5b6c4ba10fbccf4285307).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ruby_box'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_box

## Usage

```ruby
# `RubyBox::Metal` is the sandbox base class. It has only the bare essentials to get the environment working.
class MySandbox < RubyBox::Metal
  # Code in the sandbox will block at most one second
  times_out_in 1.second

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
      def add(a, b)
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
my_sandbox.execute(untrusted_program) #=> "Car"
my_sandbox.stdout #=> ["Hello, world\n"]

# Every instance of the sandbox is isolated
another_sandbox = MySandbox.new
my_sandbox.execute('$global_state') #=> nil

```

## Development

The development dependencies of this gem are managed using [Bundler](https://rubygems.org/gems/bundler).

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bundle exec rake console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [RubyGems](https://rubygems.org/gems/ruby_box).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/anarchocurious/ruby_box).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
