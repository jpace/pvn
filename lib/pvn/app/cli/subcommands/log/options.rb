#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'pvn/app/cli/subcommands/revision/multiple_revisions_option'

module PVN; module App; module CLI; module Log; end; end; end; end

module PVN::App::CLI::Log
  DEFAULT_LIMIT = 5

  class LimitOption < PVN::Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end

    def set_value val
      super val
    end
  end

  class VerboseOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', [ "include the files in the change" ], false
    end
  end

  class FormatOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :format, '-f', "use the custom (colorized) format", true, :negate => [ '-F', %r{^--no-?format} ], :as_cmdline_option => nil
    end
  end

  class HelpOption < PVN::BooleanOption
    def initialize args = Hash.new
      super :help, '-h', "display help", nil
    end
  end

  class OptionSet < PVN::OptionSet
    attr_reader :revision
    attr_reader :format
    attr_reader :help
    attr_reader :limit
    attr_reader :verbose
    
    def initialize
      super

      @limit    = add LimitOption.new
      @revision = add PVN::MultipleRevisionsRegexpOption.new(:unsets => :limit)
      @verbose  = add VerboseOption.new
      @format   = add FormatOption.new
      @help     = add HelpOption.new
    end
  end
end
