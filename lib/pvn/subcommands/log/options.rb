#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/boolean_option'
require 'pvn/subcommands/revision/multiple_revisions_option'

module PVN; module Subcommands; end; end

module PVN::Subcommands::Log
  DEFAULT_LIMIT = 5

  class LimitOption < PVN::Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end

    def set_value val
      super val.to_i
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
    has_option :revision, PVN::MultipleRevisionsRegexpOption, [ :unsets => :limit ]
    has_option :format, FormatOption
    has_option :help, HelpOption
    has_option :limit, LimitOption
    has_option :verbose, PVN::BooleanOption, [ :verbose, '-v', [ "include the files in the change" ], false ]
    
    def process args
      info "optset: #{self}".on_green
      super
      self
    end

    def paths
      unprocessed
    end
  end
end
