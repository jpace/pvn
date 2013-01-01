#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'svnx/cat/command'
require 'svnx/log/command'
require 'svnx/info/command'
require 'svnx/status/command'

# executes 'svn <command>' and returns the output as XML lines (by default,
# according to the underlying option).
module SVNx
  class Exec
    def cat path, revision, use_cache
      cmdargs = CatCommandArgs.new :path => path, :revision => revision, :use_cache => use_cache
      run_command CatCommand, cmdargs
    end
    
    def log path, revision, limit, verbose, use_cache
      cmdargs = LogCommandArgs.new :path => path, :revision => revision, :limit => limit, :verbose => verbose, :use_cache => use_cache
      run_command LogCommand, cmdargs
    end

    def info path, revision
      cmdargs = InfoCommandArgs.new :path => path, :revision => revision
      run_command InfoCommand, cmdargs
    end

    def status path, use_cache
      cmdargs = StatusCommandArgs.new :path => path, :use_cache => use_cache
      run_command StatusCommand, cmdargs
    end

    private
    def run_command cmdcls, args
      cmd = cmdcls.new args
      cmd.execute
    end
  end
end
