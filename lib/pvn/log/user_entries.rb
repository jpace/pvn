#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/entries'
require 'logue/loggable'

module PVN::Log
  class UserEntries < PVN::Log::Entries
    include Logue::Loggable

    def initialize path, options, args
      @user = args[:user]
      @limit = args[:limit]

      super path, options, args
      
      filter_entries_for_user
    end

    def has_limit?
      false
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
