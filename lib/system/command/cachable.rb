#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'system/command/line'

module PVN
  module System
    class CachableCommandLine < CommandLine
      # caches its input and values.
    end
  end
end
