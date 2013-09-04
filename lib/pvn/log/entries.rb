#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'svnx/exec'
require 'svnx/log/entries'

module PVN::Log
  class Entries < SVNx::Log::Entries
    include Logue::Loggable

    def initialize path, options, args = Hash.new
      revision = options.revision
      limit = has_limit? ? options.limit : nil
      verbose = options.files

      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      use_cache = false
      xmllines = SVNx::Exec.new.log path, revision, limit, verbose, use_cache
      super :xmllines => xmllines
    end

    def has_limit?
      true
    end
  end
end
