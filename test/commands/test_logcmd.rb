require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/commands/log'
require 'commands/command_test'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  class TestLogEntry < CommandTest
    include Loggable

    def test_log_line_regexp
      logoutput = read_testfile 'svnlog.r450.r470.txt'

      logoutput.each_with_index do |line, lidx|
        ln = line.chomp
        if PVN::Logx::Entry::LOG_SEPARATOR_RE.match(ln)
          if lidx + 1 < logoutput.length
            logline = logoutput[lidx + 1]
            md = PVN::Logx::Entry::LOG_RE.match(logline)
            assert_not_nil md, logline
          end
        end
      end
    end

    def xtest_create_from_plain_terse_text
      logoutput = IO.readlines testfile 'svnlog.r450.r470.txt'
      # info "logoutput: #{logoutput}"

      logoutput.each_with_index do |line, lidx|
        if line 
        end
      end

      entry = PVN::Logx::Entry.new :date => "somedate"
      info "entry: #{entry}"
      info "entry.date: #{entry.date}"

      assert true
    end
  end
end
