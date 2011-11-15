require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/revision'
require 'pvn/log'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class MockLogCommand < LogCommand
    @@current_file = nil
    
    def self.current_file= fname
      @@current_file = fname
    end
    
    def initialize args
      info "args: #{args}".yellow
      info "@@current_file: #{@@current_file}".yellow
      limit = args[:limit]
      n_matches = 0
      @output = Array.new
      IO.readlines(@@current_file).each do |line|
        if limit && PVN::LogCommand::LOG_REVISION_LINE.match(line)
          n_matches += 1
          if n_matches > limit
            info "done!".red
            break
          end
        end
        @output << line
      end

      info "limit: #{limit}".magenta
      info "n_matches: #{n_matches}".magenta
    end
  end

  class TestRevision < Test::Unit::TestCase
    include Loggable

    def uses fname
      MockLogCommand.current_file = File.dirname(__FILE__) + '/' + fname
    end
    
    def setup
    end

    def assert_revision exp, val
      rev = Revision.new(val, "foo", MockLogCommand)
      assert_equal exp, rev.revision
    end
    
    def test_integers
      assert_revision 4, 4
      assert_revision 4, "4"
      assert_revision 44, "44"
      assert_revision 10234, 10234
    end
    
    def test_negative_in_range
      uses "svn_long_log.txt"
      assert_revision 1222, -1
      assert_revision 1221, -2
      assert_revision 1122, -3
      assert_revision 1066, -4
    end

    def test_negative_out_of_range
      uses "svn_long_log.txt"
      assert_revision nil, -1000000
      assert_revision nil, -100000
      assert_revision nil, -10000
      assert_revision nil, -1000
      assert_revision nil, -100
      assert_revision 5, -50
      assert_revision 11, -49
    end
  end
end
