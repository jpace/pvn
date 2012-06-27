#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/command/line'

module PVN
  module System
    class CachingCommandLine < CommandLine
      # caches its input and values.

      def initialize args
        super true, args
      end
    end
  end
end
