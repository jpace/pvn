#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/entries'

module PVN::Log
  class UserEntries < PVN::Log::Entries
    include Loggable

    def initialize path, options
      @user = options.user
      @limit = options.limit

      super
      
      filter_entries_for_user
    end

    def create_cmd_args options, path
      cmdargs = super
      cmdargs[:limit] = nil      
      cmdargs
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
