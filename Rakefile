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

# TODO: Remove when mini_racer with Snapshot is officially released
require 'rake/extensiontask'
Rake::ExtensionTask.new do |ext|
  ext.name = 'mini_racer_extension'

  ext.ext_dir = 'vendor/gems/mini_racer/ext/mini_racer_extension'
  ext.lib_dir = 'vendor/gems/mini_racer/lib'
end

task :default => [:compile, :test]