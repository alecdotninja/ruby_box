require 'ruby_box/version'

require 'thread'
require 'monitor'

require 'mini_racer'
require 'json'
require 'opal'

module RubyBox
  autoload :Error, 'ruby_box/error'
  autoload :Metal, 'ruby_box/metal'
end
