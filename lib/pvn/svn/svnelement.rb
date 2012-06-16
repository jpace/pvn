#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/base/io'
require 'pvn/base/util'
require 'pvn/svn/svninfo'

module PVN
  class SVNElement
    include Loggable
    attr_reader :name

    require 'pvn/svn/svnroot'
    
    def initialize args
      RIEL::Log.info "args: #{args}"

      # $$$ this should handle local paths and full urls.
      
      # technically, name is what svn info calls "URL"
      name = args[:name]
      if name.nil? && (fname = args[:filename])
        name = fname

        if false
          debug "fname  : #{fname}"

          fullpath = Pathname.new(fname).expand_path
          debug "fullpath: #{fullpath}".yellow

          svnroot = SVNRootElement.new
          debug "svnroot: #{svnroot}"
          sri = svnroot.info
          debug "svnroot.info[:url]: #{sri[:url]}"
          debug "svnroot.info[:path]: #{sri[:path]}"
          name = svnroot.info[:url] + '/' + fname
          debug "name: #{name}"
        end
      end

      @name = name
      RIEL::Log.info "@name: #{@name}".green
    end

    def to_command subcmd, revcl, *args
      cmd = "svn #{subcmd}"
      debug "cmd: #{cmd}"
      debug "args: #{args}"
      args = args.flatten

      # revcl is [ -r, 3484 ]
      if revcl
        cmd << " -r #{revcl}"
      end
      cmd << " " << Util::quote_list(args)
      debug "cmd: #{cmd}".cyan
      cmd
    end

    def info
      SVN::Info.new :name => @name
    end

    def line_count revision = nil
      lc = nil
      
      cmd = to_command "cat", revision, @name
      ::IO.popen cmd do |io|
        lc = IO::numlines io
        debug "lc: #{lc.inspect}"
      end

      lc
    end
    
    def to_s
      @name.to_s
    end

    def inspect
      @name
    end

    def <=>(other)
      @name <=> other.name
    end
  end
end
