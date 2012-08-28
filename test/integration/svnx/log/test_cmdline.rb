#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/command'

module SVNx::Log
  class CommandLineTestCase < SVNx::Log::TestCase
    include Loggable

    def test_something
      cmdline = SVNx::LogCommandLine.new [ '/Programs/wiquery/trunk' ]
      cmdline.execute
      assert_not_nil cmdline.output
    end
  end
end
