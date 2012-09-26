#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/revision'

module PVN::Subcommands::Diff
  # an entry with a name, revision, logentry.path, and svninfo
  class LogPath
    attr_reader :name
    attr_reader :revisions
    attr_reader :logentrypath
    attr_reader :svninfo
    
    def initialize name, revision, logentrypath, svninfo
      @name = name
      @revisions = [ revision ]
      @logentrypath = logentrypath
      @svninfo = svninfo
    end

    def to_s
      inspect
    end
  end

  # represents the log entries from one revision through another.
  class LogPaths
    include Loggable

    def initialize revision, paths
      @revision = revision
      @elements = Array.new
      
      paths.each do |path|
        info "path: #{path}"
        pathelmt = PVN::IO::Element.new :local => path
        pathinfo = pathelmt.get_info
        info "pathinfo: #{pathinfo.inspect}".on_black

        elmt = PVN::IO::Element.new :local => path
        logentries = elmt.logentries @revision

        logentries.each do |logentry|
          logentry.paths.each do |lp|
            next if lp.kind != 'file'
            info "lp: #{lp}".red

            logpath = @elements.detect { |element| element.name == lp.name }
            info "logpath: #{logpath}".cyan
            if logpath
              logpath.revisions << logentry.revision
            else
              @elements << LogPath.new(lp.name, logentry.revision, lp, pathinfo)
            end
          end 
        end
      end
      info "@entries: #{@entries}".cyan
    end

    def [] idx
      @elements[idx]
    end

    def size
      @elements.size
    end

    # returns a map from names to logpaths
    def to_map
      name_to_logpath = Hash.new
      @elements.each { |logpath| name_to_logpath[logpath.name] = logpath }
      name_to_logpath
    end
  end
end
