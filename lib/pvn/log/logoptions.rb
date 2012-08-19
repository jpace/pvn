#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'pvn/app/cli/subcommands/revision/revreopt'

module PVN
  DEFAULT_LIMIT = 5

  class LimitOption < Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end
  end

  class VerboseOption < BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', [ "include the files in the change" ], false
    end
  end

  class FormatOption < BooleanOption
    def initialize optargs = Hash.new
      super :format, '-f', "use the custom (colorized) format", true, :negate => [ '-F', %r{^--no-?format} ], :as_cmdline_option => nil
    end
  end

  class LogOptionSet < OptionSet
    attr_accessor :revision
    attr_reader :format
    
    def initialize
      super

      add LimitOption.new
      @revision = add RevisionRegexpOption.new(:unsets => :limit)
      @verbose  = add VerboseOption.new
      @format   = add FormatOption.new
    end
  end
end
