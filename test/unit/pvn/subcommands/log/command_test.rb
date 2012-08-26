#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/log/options'

Log.level = Log::DEBUG

module PVN; module App; module Log; end; end; end

module PVN::App::Log
  class CommandTest < PVN::TestCase    
    def test_nothing      
    end
  end
end
