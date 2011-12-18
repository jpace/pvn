require 'pvn/util'
require 'pvn/command/cachecmd'
require 'pvn/config'

require 'pvn/subcmd/scexec'
require 'pvn/subcmd/scdoc'
require 'pvn/subcmd/scoptions'
require 'pvn/subcmd/command'

require 'pvn/option/set'

module PVN
  PVNDIFF_CMD = '/proj/org/incava/pvn/bin/pvndiff'

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
      super :whitespace, '-W', "whitespace", wsargs
    end
  end

  class DiffOptionSet < OptionSet
    attr_reader :change
    attr_reader :revision
    
    def initialize
      super
      
      @diffcmdopt = Option.new :diffcmd, "--diff-cmd", "the program to run diff through", :default => PVNDIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]
      
      self << @diffcmdopt
      self << (@change = DiffChangeOption.new)
      self << (@revision = DiffRevisionOption.new)

      # whitespaceopt = Option.new(:key => :whitespace, 
      #                            :tag => '-w',
      #                            :svnarg => '-x -w -x -b -x --ignore-eol-style',
      #                            :description => "ignore all whitespace (including blank lines and end of lines)",
      #                            :default => false)
    end
  end
  
  class DiffCommand < CachableCommand
    COMMAND = "diff"
    PVNDIFF_CMD = '/proj/org/incava/pvn/bin/pvndiff'

    attr_reader :options
    
    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Displays differences."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Compares the given files." ]
      doc.examples   << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
    end
    
    def initialize args = Hash.new
      @options = DiffOptionSet.new
      debug "args: #{args.inspect}".yellow

      super
    end

    def use_cache?
      # use cache unless the diff is against head.
      super && (@options.change.value || @options.revision.value)
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
