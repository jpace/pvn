require 'tc'

module PVN
  RESOURCE_DIR = Pathname.new(__FILE__).expand_path.parent.parent.parent + 'resources'
  puts "RESOURCE_DIR: #{RESOURCE_DIR}"

  class TestCase < Test::Unit::TestCase
    include Loggable

    WIQUERY_DIRNAME = "/Programs/wiquery/trunk"

    class << self
      def setup
        @@orig_location = Pathname.pwd
      end

      def teardown
        Dir.chdir @@orig_location
      end

      def suite
        RIEL::Log.debug "self: #{self}".negative
        @@cls = self
        RIEL::Log.debug "@@cls: #{@@cls}".negative

        ste = super
        RIEL::Log.debug "ste: #{ste}".negative

        def ste.run(*args)
          RIEL::Log.debug "self: #{self}".bold
          RIEL::Log.debug "@@cls: #{@@cls}".bold

          @@cls.setup

          RIEL::Log.debug "self: #{self}".bold

          super
          
          RIEL::Log.debug "self: #{self}".negative
          RIEL::Log.debug "@@cls: #{@@cls}".negative
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
      RESOURCE_DIR + basename
    end

    def read_testfile basename
      fname = testfile basename
      info "fname: #{fname}".on_red
      IO.readlines fname
    end

    # every testcase class must have a test method
    def test_nothing
    end
  end
end
