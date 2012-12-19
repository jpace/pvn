#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'system/command/line'

module System
  class CommandLineTestCase < PVN::TestCase
    def test_ctor
      cl = System::CommandLine.new [ "ls" ]
      assert_equal "ls", cl.to_command
    end

    def test_lshift
      cl = System::CommandLine.new [ "ls" ]
      cl << "/tmp"
      assert_equal "ls /tmp", cl.to_command
    end

    def test_execute
      cl = System::CommandLine.new [ "ls" ]
      cl << "/tmp"
      assert_equal "ls /tmp", cl.to_command
      output = cl.execute
      
      syslines = nil
      IO.popen("ls /tmp") do |io|
        syslines = io.readlines
      end

      assert_equal syslines, output
    end
  end
end
