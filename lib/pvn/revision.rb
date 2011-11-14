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
      info "num: #{num}"
      
      @revision = nil

      if n = Util.negative_integer?(numstr)
        info "negative revision: #{n}"

        # count the limit backward, and get the "first" (last) match
        limit = -1 * n
        log = logcmdclass.new(:limit => limit, :filename => fname)
        # verify N matches in output ...
        read_from_log_output 1, log.output.reverse.each
      elsif num.kind_of? Fixnum
        @revision = num
      elsif md = %r{^\+(\d+)}.match(num)
        num = md[1].to_i
        log = logcmdclass.new :filename => fname
        read_from_log_output num, log.output.reverse
      else
        @revision = n.to_i
      end
    end

    def read_from_log_output n_matches, fname
      num = md[1].to_i
      # info "num: #{num}"

      matched = 0

      # no limit on output
      log = logcmdclass.new(:filename => fname)

      log.output.reverse.each do |line|
        # info "line: #{line}"

        if md = Log::LOG_REVISION_LINE.match(line)
          # info "MATCHED: #{md}"

          matched += 1

          if matched == n_matches
            @revision = md[1].to_i
            # info "@revision: #{@revision}"
            break
          end
        end
      end

      # error: not found
    end
  end
end
