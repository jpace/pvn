#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/command'
require 'svnx/log/entries'
require 'riel/log/loggable'

module PVN::Log
  class Entries < SVNx::Log::Entries
    include RIEL::Loggable

    def initialize path, options
      cmdargs = create_cmd_args options, path
      cmdargs[:path] = path
      
      info "cmdargs: #{cmdargs}".color(:magenta)

      logargs = SVNx::LogCommandArgs.new cmdargs
      cmd = SVNx::LogCommand.new logargs
      
      super :xmllines => cmd.execute

      info { "options: #{options}" }
      info { "options.user: #{options.user}".color(:yellow) }
    end

    def create_cmd_args options, path
      cmdargs = Hash.new
      cmdargs[:path] = path      

      [ :limit, :revision ].each do |field|
        cmdargs[field] = options.send field
      end

      cmdargs[:verbose] = options.files
      
      # we can't cache this, because we don't know if there has been an svn
      # update since the previous run:
      cmdargs[:use_cache] = false
      cmdargs
    end
  end
end
