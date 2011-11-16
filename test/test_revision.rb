require File.dirname(__FILE__) + '/test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/revision'
require 'pvn/cmdexec'
# require 'mocklog'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class MockLogExecutor < CommandExecutor
    include Loggable

    def file=(fname)
      @file = fname
    end

    def run args
      info "args: #{args}".yellow
      cmd, subcmd, *cmdargs = args.split
      info "cmd: #{cmd}".yellow
      info "subcmd: #{subcmd}".yellow
      info "cmdargs: #{cmdargs}".yellow

      limit = nil

      if idx = cmdargs.index("-l")
        info "idx: #{idx}".on_blue
        limit = cmdargs[idx + 1].to_i
      end

      info "limit: #{limit}".yellow
      
      n_matches = 0
      output = Array.new
      IO.readlines(@file).each do |line|
        if limit && PVN::LogCommand::LOG_REVISION_LINE.match(line)
          n_matches += 1
          info "n_matches: #{n_matches}".yellow
          info "limit: #{limit}".yellow

          if n_matches > limit
            break
          end
        end
        output << line
      end

      puts output

      output
    end
  end

  class TestRevision < Test::Unit::TestCase
    include Loggable

    def uses fname
      @mle.file = Pathname.new(File.dirname(__FILE__) + '/files/' + fname).expand_path
    end
    
    def setup
      @mle = MockLogExecutor.new
    end

    def assert_revision exp, val
      # rev = Revision.new val, "foo", MockLogCommand
      rev = Revision.new :value => val, :fname => "foo", :executor => @mle
      assert_equal exp, rev.revision
    end
    
    def test_integers
      assert_revision 4, 4
      assert_revision 4, "4"
      assert_revision 44, "44"
      assert_revision 10234, 10234
    end
    
    def test_negative_in_range
      uses "svn/ant/core/src/full.txt"

      assert_revision 1199931, -1
      assert_revision 1199924, -2
      assert_revision 1199922, -3
      assert_revision 1190244, -4
    end

    def xtest_negative_out_of_range
      uses "svn/ant/core/src/full.txt"

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
