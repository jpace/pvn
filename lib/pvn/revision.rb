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
      @executor = args[:executor]
      info "@executor: #{@executor}"
      
      @revision = nil

      if neg = Util.negative_integer?(num)
        # if these two are the same number (revision(-3) == revision(-2)) then
        # we're at the end/beginning of the list.
        currrev = get_negative_revision neg
        if neg == -1
          info "currrev: #{currrev}"
          @revision = currrev
        else
          prevrev = get_negative_revision neg + 1
          
          info "prevrev: #{prevrev}"
          info "currrev: #{currrev}"
          
          @revision = prevrev == currrev ? nil : currrev
        end
      elsif num.kind_of? Fixnum
        @revision = num
      elsif md = %r{^\+(\d+)}.match(num)
        num = md[1].to_i
        log = LogCommand.new :filename => @fname, :executor => @executor
        info "log: #{log}"
        # info "log.output: #{log.output}"
        @revision = read_from_log_output num, log.output.reverse
      else
        @revision = num.to_i
      end
    end

    def get_negative_revision neg
      # count the limit backward, and get the "first" (last) match
      limit = -1 * neg
      info "limit: #{limit}"
      log = LogCommand.new :limit => limit, :filename => @fname, :executor => @executor
      info "log: #{log}"
      # info "log.output: #{log.output}"
      revision = read_from_log_output 1, log.output.reverse
    end

    def read_from_log_output n_matches, loglines
      loglines.each do |line|
        next unless md = PVN::LogCommand::LOG_REVISION_LINE.match(line)
        n_matches -= 1
        if n_matches == 0
          return md[1].to_i
        end
      end
      nil
    end
  end
end
