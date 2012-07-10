require 'pvn/tc'
require 'pvn/revision'
require 'svnx/log/logdata'

module PVN
  class TestRevision < PVN::TestCase
    include Loggable

    def setup
      @origdir = Pathname.pwd
      Dir.chdir WIQUERY_DIRNAME
      super
    end

    def teardown
      Dir.chdir @origdir
      super
    end

    def assert_revision exp, val
      rev = Revision.new :value => val, :fname => "pom.xml"
      assert_equal exp, rev.revision, "value: #{val}"
    end
    
    def test_integers_unconverted
      assert_revision "4", 4
      assert_revision "4", "4"
      assert_revision "44", "44"
    end
    
    def test_integers_unconverted_long_revision
      assert_revision "10234", 10234
    end
    
    def test_negative_in_range
      assert_revision 1907, -1
      assert_revision 1887, -2
      assert_revision 1847, -3
      assert_revision 1826, -4
    end

    def test_negative_out_of_range
      assert_revision nil, -1000000
      assert_revision nil, -100000
      assert_revision nil, -10000
      assert_revision nil, -1000
      assert_revision nil, -100
      assert_revision nil, -50
      assert_revision nil, -35
      assert_revision 412, -34
      assert_revision 439, -33
    end

    def test_head
      assert_revision "HEAD", "HEAD"
    end

    def test_date
      assert_revision '{' + Date.new(1997, 6, 2).to_s + '}', '{1997-06-02}'
      # assert_revision Date.new(1997, 6, 2).to_s, '{1997-06-02}:{1999-12-31}'
    end
  end
end
