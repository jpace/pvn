#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/command'
require 'rainbow'

module SVNx
  class InfoCommandLine < CommandLine
    def initialize args = Array.new
      info "args.to_a: #{args.to_a}".color(:blue)
      super "info", args.to_a
    end
  end

  class InfoCommandArgs < CommandArgs
    attr_reader :revision

    def initialize args = Hash.new
      @revision = args[:revision]
      super
    end

    def to_a
      ary = Array.new

      if @revision
        [ @revision ].flatten.each do |rev|
          ary << "-r#{rev}"
        end
      end

      if @path
        ary << @path
      end
      ary
    end
  end  

  class InfoCommand < Command
    def command_line
      InfoCommandLine.new @args
    end
  end
end
