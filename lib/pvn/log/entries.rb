#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/command'
require 'svnx/log/entries'

module PVN::Log
  class Entries < SVNx::Log::Entries
    include Loggable

    def initialize path, options
      cmdargs = Hash.new
      cmdargs[:path] = path
      
      [ :limit, :verbose, :revision ].each do |field|
        cmdargs[field] = options.send field
      end

      if options.user
        cmdargs[:limit] = nil
      end
      
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      cmdargs[:use_cache] = false

      info "cmdargs: #{cmdargs}".magenta

      logargs = SVNx::LogCommandArgs.new cmdargs
      cmd = SVNx::LogCommand.new logargs
      
      super :xmllines => cmd.execute

      info { "options: #{options}" }
      info { "options.user: #{options.user}" }

      if options.user
        filter_entries_for_user options.user, options.limit
      end
    end

    def filter_entries_for_user user, limit
      userentries = Hash.new
      each do |entry|
        break if userentries.size >= limit
        if entry.author == user
          userentries[userentries.size] = entry
        end
      end

      raise "ERROR: no matching log entries for '#{user}'" if userentries.empty?

      @entries = userentries
    end
  end
end
