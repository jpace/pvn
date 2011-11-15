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
    def initialize(numstr, fname, logcmdclass = LogCommand)
      num = numstr.kind_of?(String) ? numstr.strip : numstr
      
      @revision = nil

      if neg = Util.negative_integer?(numstr)
        # if these two are the same number (revision(-3) == revision(-2)) then
        # we're at the end/beginning of the list.
        prevrev = get_negative_revision fname, logcmdclass, neg + 1
        currrev = get_negative_revision fname, logcmdclass, neg
        @revision = prevrev == currrev ? nil : currrev
      elsif num.kind_of? Fixnum
        @revision = num
      elsif md = %r{^\+(\d+)}.match(num)
        num = md[1].to_i
        log = logcmdclass.new :filename => fname
        @revision = read_from_log_output num, log.output.reverse
      else
        @revision = num.to_i
      end
    end

    def get_negative_revision fname, logcmdclass, neg
      # count the limit backward, and get the "first" (last) match
      limit = -1 * neg
      log = logcmdclass.new :limit => limit, :filename => fname
      revision = read_from_log_output 1, log.output.reverse
    end

    def read_from_log_output n_matches, loglines
      matched = 0

      loglines.each do |line|
        next unless md = PVN::LogCommand::LOG_REVISION_LINE.match(line)
        matched += 1
        if matched == n_matches
          return md[1].to_i
        end
      end
      nil
    end
  end
end
