require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :console do
  require 'pry'
  require 'ruby_box'

  Pry.start
end

task :benchmark do
  require 'benchmark'
  require 'benchmark/ips'
  require 'ruby_box'

  Benchmark.ips do |x|
    x.report('native loop') do
      i = 0

      100000.times do |idx|
        i += idx
      end
    end

    x.report('boxed loop') do
      RubyBox.execute <<-RUBY
        i = 0

        100000.times do |idx|
          i += idx
        end
      RUBY
    end
  end
end

task :test => [:spec]
task :default => [:test]