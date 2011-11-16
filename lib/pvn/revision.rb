#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/util'
require 'pvn/log'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  class Revision
    include Loggable
    
    attr_reader :revision

    # this assumes that fname is specified, and is a filename, as opposed to '.'
    def initialize args = Hash.new
      value = args[:value]
      num = value.kind_of?(String) ? value.strip : value
      info "num        : #{num}"
      @fname = args[:fname]
      info "fname      : #{@fname}"
      @logcmdclass = args[:commandclass]
      info "logcmdclass: #{@logcmdclass}"
      @executor = args[:executor]
      info "@executor: #{@executor}"
      
      @revision = nil

      if neg = Util.negative_integer?(num)
        # if these two are the same number (revision(-3) == revision(-2)) then
        # we're at the end/beginning of the list.
        prevrev = get_negative_revision neg + 1
        currrev = get_negative_revision neg

        info "prevrev: #{prevrev}".red
        info "currrev: #{currrev}".red

        @revision = prevrev == currrev ? nil : currrev
      elsif num.kind_of? Fixnum
        @revision = num
      elsif md = %r{^\+(\d+)}.match(num)
        num = md[1].to_i
        log = LogCommand.new :filename => @fname, :executor => @executor
        info "log: #{log}"
        info "log.output: #{log.output}"
        @revision = read_from_log_output num, log.output.reverse
      else
        @revision = num.to_i
      end
    end

    def get_negative_revision neg
      # count the limit backward, and get the "first" (last) match
      limit = -1 * neg
      info "limit: #{limit}".on_green
      log = LogCommand.new :limit => limit, :filename => @fname, :executor => @executor
      info "log: #{log}"
      info "log.output: #{log.output}"
      revision = read_from_log_output 1, log.output.reverse
    end

    def read_from_log_output n_matches, loglines
      matched = 0

      loglines.each do |line|
        info "line: #{line}".red
        next unless md = PVN::LogCommand::LOG_REVISION_LINE.match(line)
        info "md: #{md}".red
        info "md: #{md.inspect}".red
        matched += 1
        info "matched: #{matched}".red
        if matched == n_matches
          info "md: #{md[1]}".red
          return md[1].to_i
        end
      end
      nil
    end
  end
end
