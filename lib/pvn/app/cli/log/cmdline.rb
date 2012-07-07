#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/revision'

module PVN
  module App
    module Log
      class CmdLineArgs
        include Loggable

        attr_reader :limit
        attr_reader :revision
        attr_reader :path

        def initialize args
          @limit = nil
          while !args.empty?
            arg = args.shift
            info "arg: #{arg}".cyan
            case arg
            when "--limit", "-l"
              @limit = args.shift.to_i
            when %r{-r(.*)}
              md = Regexp.last_match
              info "md: #{md}".on_yellow
              @revision = Revision.new :value => md[1]
            else
              @path = arg
            end
          end
        end
      end
    end
  end
end
