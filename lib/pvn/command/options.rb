#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'synoption/fixnum_option'

module PVN; module Command; end; end

module PVN::Command
  class HelpOption < Synoption::BooleanOption
    def initialize args = Hash.new
      super :help, '-h', "display help", nil
    end
  end

  class VerboseOption < Synoption::BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', [ "display verbose output" ], false
    end

    def set_value val
      Logue::Log.level = Logue::Log::DEBUG
    end
  end

  class OptionSet < Synoption::OptionSet
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
