#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/entries'
require 'svnx/exec'
require 'riel/log/loggable'

module PVN::Log
  class Entries < SVNx::Log::Entries
    include RIEL::Loggable

    def initialize path, options
      revision = options.revision
      limit = limit options
      verbose = options.files

      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      use_cache = false
      xmllines = SVNx::Exec.new.log path, revision, limit, verbose, use_cache
      super :xmllines => xmllines
    end

    def limit options
      options.limit
    end
  end
end
