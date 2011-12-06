require 'pvn/util'
require 'pvn/command/command'
require 'pvn/config'

module PVN
  class DiffCommand < Command
    COMMAND = "diff"
    
    # has_option :whitespace, '-w', "whether to consider whitespace", :default => false, :negate => [ %r{^--no-?whitespace} ]
    # has_option :javadiff, '-j', "specify the program for diffing java files"

    self.doc do |doc|
      doc.subcommands = [ COMMAND ]
      doc.description = "Displays differences."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Compares the given files." ]
      doc.examples << [ "pvn diff foo.rb", "Compares foo.rb against the last updated version." ]
    end

    DIFF_CMD = '/proj/org/incava/pvn/bin/pvndiff'
    has_option :diffcmd, "--diff-cmd", "the program to run diff through", :default => DIFF_CMD, :negate => [ %r{^--no-?diff-?cmd} ]
    has_revision_option

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
