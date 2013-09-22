require 'rubygems'
require 'logue/log'
require 'stringio'
require 'test/unit'
require 'resources'
require 'rainbow'

# no verbose if running all tests:
level = ARGV.detect { |x| x.index '**' } ? Logue::Log::WARN : Logue::Log::DEBUG

Logue::Log.level = level
Logue::Log.set_widths(-35, 4, -35)

# produce colorized output, even when redirecting to a file:
Sickill::Rainbow.enabled = true

module PVN
  class TestCase < Test::Unit::TestCase
    include Logue::Loggable
    
    def setup
    end
  end
end
