#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'pvn/app/cli/subcommands/revision/revision_option'

module PVN
  thisfile = Pathname.new __FILE__
  PVNDIFF_CMD = (thisfile.parent.parent.parent.parent + "bin/pvndiff").expand_path

  POS_NEG_NUMERIC_RE = Regexp.new('^[\-\+]?\d+$')
  
  # "pvn diff -3" == "pvn diff -c -3", not "pvn diff -r -3", because
  # we diff for the change, not from that revision to head.

  class DiffRevisionOption < RevisionOption
    def head?
      value.nil? || value == 'HEAD'
    end
  end
  
  class DiffChangeOption < Option
    def initialize chgargs = Hash.new
      chgargs[:setter] = :revision_from_args
      chgargs[:regexp] = POS_NEG_NUMERIC_RE
      
      super :change, '-c', "change", chgargs
    end
  end

  class DiffWhitespaceOption < Option
    def initialize wsargs = Hash.new
      super :whitespace, '-W', "ignore all whitespace", wsargs
    end

    def to_command_line
      if value
        %w{ -x -w -x -b -x --ignore-eol-style }
      end
    end
  end

  class DiffOptionSet < OptionSet
    attr_reader :change
    attr_reader :revision
    
    def initialize
      super
      
      # diffcmd is old/new option style (non-subclass of Option)
      diffcmd = PVNDIFF_CMD.exist? && PVNDIFF_CMD
      @diffcmdopt = add Option.new :diffcmd, "--diff-cmd", "the program to run diff through", diffcmd, :negate => [ %r{^--no-?diff-?cmd} ]
      @change     = add DiffChangeOption.new
      @revision   = add DiffRevisionOption.new
      @whitespace = add DiffWhitespaceOption.new
    end
  end
end
