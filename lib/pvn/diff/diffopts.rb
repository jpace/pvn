#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/option/set'

module PVN
  thisfile = Pathname.new __FILE__
  PVNDIFF_CMD = (thisfile.parent.parent.parent.parent + "bin/pvndiff").expand_path
  
  # PVNDIFF_CMD = '/proj/org/incava/pvn/bin/pvndiff'

  # module Diff
  #   COMMAND = "diff"

  #   class DiffExec < Subcommand::Exec
  #   end

  #   class DiffDoc < Subcommand::Doc
  #     # subcommands = [ COMMAND ]
  #     # description = "Displays differences."
  #     # usage       = "[OPTIONS] FILE..."
  #     # summary     = [ "Compares the given files." ]
  #     # examples   << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
  #   end

  #   class DiffOptions < Subcommand::Options
  #     def initialize
  #       super

  #       @diffcmdopt = Option.new :diffcmd, "--diff-cmd", "the program to run diff through", :default => PVNDIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]

  #       self << @diffcmdopt
  #     end
  #   end

  #   class DiffSubcmd < Subcommand::Command
  #     def initialize
  #       super(:executor => DiffExec.new, :documentor => DiffDoc.new, :options => DiffOptions.new)
  #     end

  #     def execute args
  #       @executor.run @options, args
  #     end
  #   end
  # end

  # "pvn diff -3" == "pvn diff -c -3", not "pvn diff -r -3", because
  # we diff for the change, not from that revision to head.

  class DiffRevisionOption < Option
    def initialize revargs = Hash.new
      revargs[:setter] = :revision_from_args      
      super :revision, '-r', "revision", revargs
    end

    def head?
      value.nil? || value == 'HEAD'
    end
  end
  
  class DiffChangeOption < Option
    def initialize chgargs = Hash.new
      chgargs[:setter] = :revision_from_args
      chgargs[:regexp] = PVN::Util::POS_NEG_NUMERIC_RE
      
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
      @diffcmdopt = add Option.new :diffcmd, "--diff-cmd", "the program to run diff through", :default => PVNDIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]
      @change     = add DiffChangeOption.new
      @revision   = add DiffRevisionOption.new
      @whitespace = add DiffWhitespaceOption.new
    end
  end
end
