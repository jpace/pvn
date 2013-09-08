#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'
require 'logue/loggable'
require 'svnx/exec'

module PVN::Log
  class UserEntries < SVNx::Log::Entries
    include Logue::Loggable

    def initialize path, args = Hash.new
      @user = args[:user]
      @limit = args[:limit]
      
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      use_cache = false
      xmllines = SVNx::Exec.new.log path, args[:revision], nil, args[:files], use_cache
      super :xmllines => xmllines
      
      filter_entries_for_user
    end

    def filter_entries_for_user
      userentries = Hash.new
      each do |entry|
        break if userentries.size >= @limit
        if entry.author == @user
          userentries[userentries.size] = entry
        end
      end

      raise "ERROR: no matching log entries for '#{@user}'" if userentries.empty?

      @entries = userentries
    end
  end
end
