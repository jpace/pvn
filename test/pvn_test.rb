require 'test_helper'
require 'runit/testcase'
require 'pvn/tc'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

__END__
module PVN
  class TestCase < RUNIT::TestCase
    include Loggable

    WIQUERY_DIRNAME = "/Programs/wiquery/trunk"

    class << self
      def setup
        # RIEL::Log.debug "setting up: #{self}".on_blue
        @@orig_location = Pathname.pwd
      end

      def teardown
        # RIEL::Log.debug "tearing down: #{self}".on_yellow
        Dir.chdir @@orig_location
      end

      def suite
        # RIEL::Log.debug "self: #{self}".negative
        @@cls = self
        # RIEL::Log.debug "@@cls: #{@@cls}".negative

        ste = super
        # RIEL::Log.debug "ste: #{ste}".negative

        def ste.run(*args)
          # RIEL::Log.debug "self: #{self}".bold
          # RIEL::Log.debug "@@cls: #{@@cls}".bold

          @@cls.setup

          # RIEL::Log.debug "self: #{self}".bold

          super
          
          # RIEL::Log.debug "self: #{self}".negative
          # RIEL::Log.debug "@@cls: #{@@cls}".negative
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
