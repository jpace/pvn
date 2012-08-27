#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/log/command'

Log.level = Log::DEBUG

module PVN; module App; module Log; end; end; end

module PVN::App::Log
  class CommandTest < PVN::TestCase
    
    def test_path
      PVN::Subcommands::Log::Command.new %w{ /Programs/wiquery/trunk/pom.xml }
    end
    
    def test_invalid_path
      assert_raises(RuntimeError) do
        PVN::Subcommands::Log::Command.new %w{ /this/doesnt/exist }
      end
    end
  end
end
