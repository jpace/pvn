#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/revision'
require 'pvn/subcommands/diff/logpath'

module PVN::Subcommands::Diff
  # represents the log entries from one revision through another.
  class LogPaths
    include Loggable

    def initialize revision, paths
      @revision = revision
      @elements = Array.new
      
      paths.each do |path|
        info "path: #{path}".blue
        pathelmt = PVN::IO::Element.new :local => path
        pathinfo = pathelmt.get_info
        elmt = PVN::IO::Element.new :local => path
        info "@revision: #{@revision}".yellow
        logentries = elmt.logentries @revision

        logentries.each do |logentry|
          logentry.paths.each do |logentrypath|
            next if logentrypath.kind != 'file'
            add_log_entry_path logentry, logentrypath, pathinfo
          end 
        end

        if @revision.working_copy?
          info "getting status".cyan
          status = elmt.find_files_by_status
          info "status: #{status}"
          info "status.entries: #{status.entries}"
          status.entries.each do |entry|
            info "entry: #{entry}".red
            name = entry.path
            info "name: #{name}"
            rev = :working_copy
            info "rev: #{rev}"
            action = entry.status
            info "action: #{action}"
            unless action == 'unversioned'
              # add_log_status_path entry.path, :working_copy, action, 
            end
          end
        end
      end
    end

    def add_log_entry_path logentry, logentrypath, pathinfo
      name = logentrypath.name
      logpath = @elements.detect { |element| element.name == name }
      if logpath
        logpath.revisions << logentry.revision
      else
        @elements << LogPath.new(name, logentry.revision, logentrypath, pathinfo)
      end
    end

    def add_log_status_path name, revision, action, url
      logpath = @elements.detect { |element| element.name == name }
      if logpath
        info "logpath: #{logpath}"
        logpath.revisions << revision
      else
        @elements << LogPath.new(name, revision, nil, nil, action, url)
      end
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
