require 'test_helper'
require 'runit/testcase'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestCase < RUNIT::TestCase
    include Loggable

    WIQUERY_DIRNAME = "/Programs/wiquery/trunk"

    class << self
      def setup
        RIEL::Log.info "setting up".on_blue
        @@orig_location = Pathname.pwd
        # super
      end

      def teardown
        RIEL::Log.info "tearing down".on_yellow
        Dir.chdir @@orig_location
      end

      def suite
        RIEL::Log.info "self: #{self}".negative
        @@cls = self

        ste = super
        def ste.run(*args)
          @@cls.setup
          super
          @@cls.teardown
        end
        ste
      end
    end

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
