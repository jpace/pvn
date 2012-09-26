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

    def test_user
      # filter_for_user
      # fetch_log_in_pieces (-n LIMIT, LIMIT * 2, LIMIT * 4, LIMIT * 8 ... )
      # PVN::Subcommands::Log::Command.new [ PT_DIRNAME ]
    end

  end
end
