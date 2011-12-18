#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/command/cmdexec'
require 'pvn/option/optional'
require 'pvn/util'

$orig_file_loc = Pathname.new(__FILE__).expand_path

module PVN
  class RevisionOption < Option
    attr_accessor :fromdate
    attr_accessor :todate
    
    def initialize revargs = Hash.new
      revargs[:setter] = :revision_from_args
      revargs[:regexp] = PVN::Util::POS_NEG_NUMERIC_RE
      @fromdate = nil
      @todate = nil
      super :revision, '-r', "revision", revargs
    end
    
    def value
      val = nil
      if @fromdate
        val = to_svn_revision_date @fromdate
      end

      if @todate
        val = val ? val + ':' : ''
        val += to_svn_revision_date @todate
      end

      if val
        val
      else
        super
      end
    end

    def xxxset
      # @todo
      require @@orig_file_loc.dirname.parent + 'revision.rb'
      Revision.revision_from_args optset, cmdargs
    end
  end

  class Command
    include Optional
    include Loggable

    def self.has_revision_option revopts = Hash.new
      options << RevisionOption.new(revopts)
    end
    
    def self.revision_from_args optset, cmdargs
      require $orig_file_loc.dirname.parent + 'revision.rb'
      Revision.revision_from_args optset, cmdargs
    end

    attr_reader :output

    def initialize args = Hash.new
      debug "args: #{args}".red
      @execute  = args[:execute].nil? || args[:execute]
      @executor = args[:executor] || CommandExecutor.new
      cmdargs   = args[:command_args] || Array.new

      options.process self, args, cmdargs
      fullcmdargs = options.to_command_line + cmdargs

      info "fullcmdargs: #{fullcmdargs}".green
      
      if args[:filename]
        fullcmdargs << args[:filename]
      end

      @svncmd = to_svn_command fullcmdargs
      run @svncmd
    end

    def to_svn_command fullcmdargs
      [ "svn", self.class::COMMAND ] + fullcmdargs
    end

    def command
      @svncmd.join(" ")
    end

    def to_s
      command
    end

    def run args
      info "self.class: #{self.class}"
      info "@command  : #{command}".on_black
      info "@execute  : #{@execute}".on_black

      if @execute
        info "@executor : #{@executor}"
        @output = @executor.run command
      else
        debug "not executing: #{command}".red
      end
    end

    def option optname
      self.class.find_option optname
    end

    def options
      # self.class.options
    end

    def run_command
      @output = @executor.run(command)
    end
  end
end
