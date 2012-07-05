#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  module App
    module Log
      class CmdLineArgs
        include Loggable

        attr_reader :limit

        def initialize args
          @limit = nil
          while !args.empty?
            arg = args.shift
            info "arg: #{arg}".cyan
            case arg
            when "--limit", "-l"
              @limit = args.shift.to_i
            end
          end
        end
      end
    end
  end
end
