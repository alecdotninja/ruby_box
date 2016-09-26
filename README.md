# RubyBox

RubyBox allows the execution of untrusted Ruby code safely in a sandbox.

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
class MySandbox < RubyBox::Metal
  times_out_in 1.second
  
  executes <<-RUBY
    # Some boilerplate code
    class PlayThing
      attr_reader :name
    
      def initialize(name)
        @name = name
      end
    end
  RUBY
end

untrusted_program = <<-RUBY
  puts "Hello, world"
  
  car = PlayThing.new("Car")
  car.name
RUBY

my_sandbox = MySandbox.new
my_sandbox.execute(untrusted_program) #=> "Car"
my_sandbox.stdout #=> ["Hello, world\n"]

```

## Development

The development dependencies of this gem are managed using [Bundler](https://rubygems.org/gems/bundler).

After checking out the repo, run `bundle install` to install dependencies. Then, run `bundle exec rake spec` to run the tests. You can also run `bundle exec rake console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [RubyGems](https://rubygems.org/gems/ruby_box).

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/anarchocurious/ruby_box).


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
