require 'pvn/util'
require 'pvn/command/command'
require 'pvn/config'

require 'pvn/subcmd/scexec'
require 'pvn/subcmd/scdoc'
require 'pvn/subcmd/scoptions'
require 'pvn/subcmd/command'

module PVN
  module Diff
    COMMAND = "diff"

    class DiffExec < Subcommand::Exec
    end

    class DiffDoc < Subcommand::Doc
      # subcommands = [ COMMAND ]
      # description = "Displays differences."
      # usage       = "[OPTIONS] FILE..."
      # summary     = [ "Compares the given files." ]
      # examples   << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
    end

    class DiffOptions < Subcommand::Options
      def initialize
        super

        @diffcmdopt = Option.new :diffcmd, "--diff-cmd", "the program to run diff through", :default => PVNDIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]

        self << @diffcmdopt
      end
    end

    class DiffSubcmd < Subcommand::Command
      def initialize
        super(:executor => DiffExec.new, :documentor => DiffDoc.new, :options => DiffOptions.new)
      end

      def execute args
        @executor.run @options, args
      end
    end
  end

  class DiffCommand < Command
    COMMAND = "diff"
    PVNDIFF_CMD = '/proj/org/incava/pvn/bin/pvndiff'
    
    # has_option :whitespace, '-w', "whether to consider whitespace", :default => false, :negate => [ %r{^--no-?whitespace} ]
    # has_option :javadiff, '-j', "specify the program for diffing java files"

    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Displays differences."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Compares the given files." ]
      doc.examples   << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
    end

    diffcmdopt = Option.new :diffcmd, "--diff-cmd", "the program to run diff through", :default => PVNDIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]
    changeopt = Option.new :change, '-c', "the change made by revision ARG", { :setter => :revision_from_args }
    # whitespaceopt = Option.new :whitespace, '-w', "ignore all whitespace (including blank lines and end of lines)", :default => false
    
    # whitespaceopt = Option.new(:key => :whitespace, 
    #                            :tag => '-w',
    #                            :svnarg => '-x -w -x -b -x --ignore-eol-style',
    #                            :description => "ignore all whitespace (including blank lines and end of lines)",
    #                            :default => false)

    # changeopt = Option.new(:key => :change,
    #                        :tag => '-c', 
    #                        :svnarg => '-c (#{revision_from_args(args.next)})',
    #                        :description => "the change made by revision ARG")
    
    options do |optset|
      optset.options << diffcmdopt
      optset.options << changeopt
      # optset.options << whitespaceopt 
    end
    # has_option :diffcmd, "--diff-cmd", "the program to run diff through", :default => DIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]
    has_revision_option

    def initialize args = Hash.new
      debug "args: #{args.inspect}".yellow

      super
    end
    
    # @todo implement
    if true
      self.options do |opts|
        # opts.add :diffcmd
      end
    end

    def xxxrun args
      info "running!".on_blue
      info "args: #{args}".on_blue

      # this will be on a file-by-file basis, using specific diff programs for the file type.

      pn = Pathname.new __FILE__
      # info "pn: #{pn}".on_red

      # usediffopt = find_option :diffcmd

      differ = (pn + '../../../../bin/pvndiff').expand_path 
      # info "differ: #{differ}"

      args.insert 0, "--diff-cmd", differ
      super
    end
  end
end
