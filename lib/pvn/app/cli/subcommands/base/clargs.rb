#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/revision'

module PVN
  module App
    module Subcommand
      class CmdLineArgs
        include Loggable

        def initialize args
          while !args.empty?
            arg = args.shift
            info "arg: #{arg}".cyan
            case arg
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
