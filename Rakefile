require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :console do
  require 'ruby_box'
  require 'pry'

  Pry.start
end

task :benchmark do
  require 'benchmark'
  require 'ruby_box'

  Benchmark.bm do |benchmark|
    benchmark.report('native') do
      i = 0

      1000.times do |idx|
        i += idx
      end
    end

    benchmark.report('boxed') do
      RubyBox.eval '
        i = 0

        1000.times do |idx|
          i += idx
        end
      '
    end
  end

  Benchmark.bm do |benchmark|
    benchmark.report('box') do
      RubyBox.eval '
        nil
      '
    end

    benchmark.report('box + loop') do
      RubyBox.eval '
        i = 0

        1000.times do |idx|
          i += idx
        end
      '
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

task :default => :spec