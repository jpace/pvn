#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command'

module PVN
  class DiffCommand < Command
    has_option :something, '-s', "DESCRIPTION"
  end
end
