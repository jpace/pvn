#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/util'
require 'pvn/log/logcmd'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  class Revision
    include Loggable

    DATE_REGEXP = Regexp.new('^\{(.*?)\}')

    def self.revision_from_args optset, cmdargs
      revarg = cmdargs.shift
      RIEL::Log.debug "revarg: #{revarg}"
      RIEL::Log.debug "cmdargs: #{cmdargs}"

      rev = Revision.new(:fname => cmdargs[-1], :value => revarg, :use_cache => false).revision
      RIEL::Log.debug "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{cmdargs[-1]}"
      end
      rev
    end
    
    attr_reader :revision

    # this assumes that fname is specified, and is a filename, as opposed to '.'
    def initialize args = Hash.new
      value = args[:value]
      num = value.kind_of?(String) ? value.strip : value
      debug "num        : #{num}".yellow
      @fname = args[:fname]
      debug "fname      : #{@fname}".yellow
      @executor = args[:executor]
      debug "@executor: #{@executor}"
      
      @revision = nil

      from, to = num.kind_of?(String) ? num.split(':') : num

      @revision = convert_to_revision from
      if to
        @revision += ':' + convert_to_revision(to)
      end
    end

    def convert_to_revision arg
      if arg == "HEAD"
        @revision = "HEAD"
      elsif neg = Util.negative_integer?(arg)
        get_negative_revision neg
      elsif arg.kind_of? Fixnum
        @revision = arg
      elsif md = DATE_REGEXP.match(arg)
        info "md: #{md.inspect}".on_red
        @revision = md[0]
      elsif md = %r{^\+(\d+)}.match(arg)
        arg = md[1].to_i
        debug "arg: #{arg}"
        @revision = get_revision @fname, nil, arg
      else
        @revision = arg.to_i
      end
    end

    def get_negative_revision neg
      debug "neg        : #{neg}"

      # if these two are the same number (revision(-3) == revision(-2)) then
      # we're at the end/beginning of the list.
      currrev = get_negative_revision_unchecked neg
      if neg == -1
        debug "currrev: #{currrev}"
        @revision = currrev
      else
        debug "neg        : #{neg}"
        prevrev = get_negative_revision_unchecked neg + 1
        
        debug "prevrev: #{prevrev}"
        debug "currrev: #{currrev}"

        # $$$ does -r 123 -l 2 == -r 123 -l 3?
        @revision = prevrev == currrev ? nil : currrev
        # @revision = prevrev == currrev ? currrev : currrev
      end
    end

    def get_negative_revision_unchecked neg
      # count the limit backward, and get the "first" (last) match
      limit = -1 * neg
      get_revision @fname, limit, 1
    end

    def get_revision fname, limit, num
      logcmd = run_log_command fname, limit
      get_nth_revision logcmd, num
    end

    def get_nth_revision logcmd, num
      read_from_log_output num, logcmd.output.reverse
    end

    def read_from_log_output n_matches, loglines
      loglines.each do |line|
        next unless md = PVN::Log::SVN_LOG_SUMMARY_LINE_RE.match(line)
        n_matches -= 1
        if n_matches == 0
          return md[1].to_i
        end
      end
      nil
    end

    def run_log_command fname, limit
      LogCommand.new :limit => limit, :filename => fname, :executor => @executor
    end
  end
end
