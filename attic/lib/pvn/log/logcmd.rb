#!/usr/bin/ruby -w
# -*- ruby -*-

require 'system/command'
require 'system/cachecmd'
require 'pvn/svn/command/svncmd'
require 'pvn/log/logfactory'
require 'pvn/log/logoptions'

module PVN
  class LogCommand < SVNCommand
    COMMAND = "log"
    REVISION_ARG = '-r'

    attr_reader :options

    self.doc do |doc|
      doc.subcommands = [ COMMAND, 'l' ]
      doc.description = "Print log messages for the given files."
      doc.usage       = "[OPTIONS] FILE..."
      doc.summary     = [ "Prints the log entries for the given files, with colorized",
                          "output. Unlike 'svn log', which prints all log entries, ",
                          "'pvn log' prints #{DEFAULT_LIMIT} entries by default.",
                          "As with other pvn commands, 'pvn log' accepts relative ",
                          "revisions."
                        ]
      doc.options.concat LogOptionSet.new.options
      doc.examples   << [ "pvn log foo.rb",       "Prints the latest #{DEFAULT_LIMIT} log entries for foo.rb." ]
      doc.examples   << [ "pvn log -l 25 foo.rb", "Prints 25 log entries for the file." ]
      doc.examples   << [ "pvn log -3 foo.rb",    "Prints the log entry for revision (HEAD - 3)." ]
      doc.examples   << [ "pvn log +3 foo.rb",    "Prints the 3rd log entry." ]
      doc.examples   << [ "pvn log -l 10 -F",     "Prints the latest 10 entries, unformatted." ]
      doc.examples   << [ "pvn log -r 122 -v",    "Prints log entry for revision 122, with the files in that change." ]
    end
    
    def initialize args = Hash.new
      @options = LogOptionSet.new
      
      debug "args: #{args.inspect}"
      
      @options.revision.fromdate = args[:fromdate]
      @options.revision.todate = args[:todate]

      @options.options.each do |opt|
        info "opt: #{opt}".blue
      end

      @entries = nil

      super
    end

    def has_entries?
      true
    end

    def use_cache?
      # use cache unless log is to head.
      super && !@options.revision.head?
    end

    def entries
      @entries ||= begin
                     # of course this assumes that output is in plain text (non-XML)
                     factory = PVN::Log::TextFactory.new output
                     factory.entries
                   end
    end

    def revision_of_nth_entry num
      entry = nth_entry num
      entry && entry.revision.to_i
    end

    def nth_entry n
      entries[-1 * n]
    end

    def write_entries
      info "@options: #{@options.inspect}"
      info "@options.format: #{@options.format.inspect}".yellow

      entries.each do |entry|
        info "@options.format.value: #{@options.format.value}"
        entry.write @options.format.value
      end
      unless @options.format
        puts PVN::Log::Entry::BANNER
      end
    end

    # this may be faster than get_nth_entry
    def read_from_log_output n_matches
      loglines = output.reverse

      entries = entries
      entry = entries[-1 * n_matches]
      
      if true
        return entry && entry.revision.to_i
      end

      loglines.each do |line|
        next unless md = SVN_LOG_SUMMARY_LINE_RE.match(line)
        
        info "md: #{md}".yellow
        
        n_matches -= 1
        if n_matches == 0
          return md[1].to_i
        end
      end
      nil
    end
  end
end

module PVN::Log
  class Command < CachableCommand
    def initialize args
      command = %w{ svn log }

      # todo: handle revision conversion:
      fromrev = args[:fromrev]
      torev   = args[:torev]

      if fromrev && torev
        command << "-r" << "#{fromrev}:#{torev}"
      elsif args[:fromdate] && args[:todate]
        command << "-r" << "\{#{fromdate}\}:\{#{todate}\}"
      end
      debug "command: #{command}".on_red
    end
  end
end
