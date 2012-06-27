require 'tc'
require 'system/command/line'

module PVN
  module System
    class CommandLineTestCase < PVN::TestCase
      include Loggable

      def test_ctor
        cl = PVN::System::CommandLine.new false, [ "ls" ]
        assert_equal "ls", cl.to_command
      end

      def test_lshift
        cl = PVN::System::CommandLine.new false, [ "ls" ]
        cl << "/tmp"
        assert_equal "ls /tmp", cl.to_command
      end

      def test_execute
        cl = PVN::System::CommandLine.new false, [ "ls" ]
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
end
