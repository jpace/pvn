#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'svnx/exec'
require 'svnx/log/entries'

module PVN::Log
  class Entries < SVNx::Log::Entries
    include Logue::Loggable

    def initialize path, args = Hash.new
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      use_cache = false
      xmllines = SVNx::Exec.new.log path, args[:revision], args[:limit], args[:files], use_cache
      super :xmllines => xmllines
    end
  end
end
