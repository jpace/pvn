#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'synoption/fixnum_option'

module PVN; module Command; end; end

module PVN::Command
  class HelpOption < PVN::BooleanOption
    def initialize args = Hash.new
      super :help, '-h', "display help", nil
    end
  end

  class VerboseOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', [ "display verbose output" ], false
    end

    def set_value val
      RIEL::Log.level = RIEL::Log::DEBUG
    end
  end

  class OptionSet < PVN::OptionSet
    has_option :help,       HelpOption
    has_option :verbose,    VerboseOption

    def name
      self.class.to_s.split('::')[-2].downcase
    end

    def paths
      unprocessed
    end
  end
end
