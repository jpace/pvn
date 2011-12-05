require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'runit/testcase'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestCase < RUNIT::TestCase
    include Loggable

    WIQUERY_DIRNAME = "/Programs/wiquery/trunk"

    def initialize(*args)
      # save this because expand_path resolves to the current dir, which we
      # change during the tests.
      @original_dir = Pathname.new(__FILE__).expand_path
      super
    end

    def testfile basename
      @original_dir + '../files' + basename
    end

    def read_testfile basename
      IO.readlines testfile basename
    end

    # every testcase class must have a test method
    def test_nothing
    end
  end
end
