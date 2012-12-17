#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/status/command'
require 'resources'
require 'stringio'

Log.level = Log::DEBUG

module PVN::Status
  class CommandTest < PVN::IntegrationTestCase

    def test_local
      explines = Array.new

      explines << "    \e[33mFirstFile.txt\e[0m"
      explines << "    \e[32mSeventhFile.txt\e[0m"
      explines << "    \e[31mdirzero/SixthFile.txt\e[0m"
      explines << "    src/java/Charlie.java"
      explines << "    \e[32msrc/ruby/dog.rb\e[0m"
      
      assert_command_output PVN::Status::Command, %w{ }, explines
    end
  end
end
