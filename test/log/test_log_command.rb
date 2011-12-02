require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/log/command'
require 'pvn/log/entry'
require 'pvn_cmd_test'

RIEL::Log.level = Log::DEBUG
RIEL::Log.set_widths(-12, 4, -35)

module PVN
  class TestLogCommand < PVN::CommandTestCase
    include Loggable

    LOG_SEP_LINE = "------------------------------------------------------------------------"

    def test_default_output
      lc = LogCommand.new Hash.new
      output = lc.run Array.new
      info "output: #{output}"

      output.each_with_index do |line, lidx|
        info "output[#{lidx}]: #{line}"
      end

      # the last 5 entries happen to be four lines apart, with only one line of
      # comment text each.
      [ 0, 4, 8, 12, 16, 20 ].each do |lnum|
        assert_equals LOG_SEP_LINE, output[lnum].chomp, "log entry separator line"
      end

      # @todo - extend the tests for output
    end

    def test_default_entries
      lc = LogCommand.new Hash.new

      entries = lc.entries
      info "entries: #{entries}"
      
      assert_equal 5, entries.length, "number of entries for default log command"
    end

    def test_verbose_entries
      lc = LogCommand.new :command_args => %w{ -v }
      
      entries = lc.entries
      info "entries: #{entries}"
      
      assert_equal 5, entries.length, "number of entries for default log command"
    end
  end
end
