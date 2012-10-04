#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/options'
require 'pvn/command/command'
require 'tempfile'

$io = $stdout

module PVN::Diff
  class Differ
    include Loggable

    attr_reader :whitespace
    attr_reader :revision
    
    def initialize options
      @whitespace = options.whitespace
      @options = options
    end
  end
end
