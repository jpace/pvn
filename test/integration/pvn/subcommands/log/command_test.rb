#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/subcommands/log/command'

module PVN; module App; module Log; end; end; end

module PVN::App::Log
  class CommandTest < PVN::IntegrationTestCase
    
    def test_path
      PVN::Subcommands::Log::Command.new [ PT_DIRNAME ]
    end
    
    def test_invalid_path
      assert_raises(RuntimeError) do
        PVN::Subcommands::Log::Command.new %w{ /this/doesnt/exist }
      end
    end
  end
end
