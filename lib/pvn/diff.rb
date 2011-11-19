#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util'
require 'pvn/command'
require 'pvn/revision'
require 'pvn/cmdargs'
require 'pvn/options'

module PVN
  class DiffCommand < Command
    extend Optional

    has_option :something, '-s'
  end
end
