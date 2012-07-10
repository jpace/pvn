#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/log/logcmd'

module PVN
  # Returns the Nth revision from the given logging output.

  # -n means to count from the end of the list.
  # +n means to count from the beginning of the list.
  #  n means the literal revision number.  
  class Revision
    include Loggable

    DATE_REGEXP = Regexp.new('^\{(.*?)\}')
    SVN_REVISION_WORDS = %w{ HEAD BASE COMMITTED PREV }

    def self.revision_from_args optset, optargs
      revarg = optargs.shift
      RIEL::Log.debug "revarg: #{revarg}"
      RIEL::Log.debug "optargs: #{optargs}"

      rev = Revision.new(:fname => optset.arguments[0], :value => revarg, :use_cache => false).revision
      RIEL::Log.debug "rev: #{rev}"

      if rev.nil?
        raise ArgumentError.new "invalid revision: #{revarg} on #{optargs[-1]}"
      end
      rev
    end
    
    attr_reader :revision

    def initialize args = Hash.new
      debug "args        : #{args}".yellow
      value = args[:value]
      num = value.kind_of?(String) ? value.strip : value
      debug "num        : #{num}".yellow
      @fname = args[:fname]
      debug "fname      : #{@fname}".yellow
      
      @revision = nil

      from, to = num.kind_of?(String) ? num.split(':') : num
      info "from: #{from}; to: #{to}".on_blue
      info "from: #{from.class}; to: #{to.class}".on_blue

      @revision = convert_to_revision from
      if to
        @revision += ':' + convert_to_revision(to)
      end

      info "@revision: #{@revision}; #{@revision.class}"
    end

    def to_s
      @revision
    end

    def convert_to_revision arg
      if SVN_REVISION_WORDS.include? arg
        info "word: #{arg}"
        arg
      elsif neg = Integer.negative?(arg)
        info "neg: #{arg}"
        get_negative_revision neg
      elsif arg.kind_of? Fixnum
        info "fixnum: #{arg}"
        arg.to_s
      elsif md = DATE_REGEXP.match(arg)
        info "md: #{md.inspect}".on_red
        md[0]
      elsif md = %r{^\+(\d+)}.match(arg)
        arg = md[1].to_i
        debug "arg: #{arg}"
        get_revision @fname, nil, arg
      else
        arg.to_s
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
      logcmd = LogCommand.new :limit => limit, :command_args => [ fname ]
      entries = logcmd.entries
      entry = entries[-1 * num]
      entry && entry.revision.to_i
    end
  end
end
