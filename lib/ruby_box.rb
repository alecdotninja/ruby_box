require 'ruby_box/version'

require 'thread'
require 'monitor'

require 'mini_racer'
require 'opal'

module RubyBox
  class Error < StandardError; end

  autoload :Metal, 'ruby_box/metal'
end
