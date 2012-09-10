#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'synoption/fixnum_option'

module PVN; module Subcommands; end; end

module PVN::Subcommands::Base
  class HelpOption < PVN::BooleanOption
    def initialize args = Hash.new
      super :help, '-h', "display help", nil
    end
  end

  class OptionSet < PVN::OptionSet
    def name
      self.class.to_s.split('::')[-2].downcase
    end

    def paths
      unprocessed
    end
  end
end
