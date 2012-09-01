#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/fixnum_option'
require 'synoption/boolean_option'
require 'pvn/subcommands/revision/multiple_revisions_option'
require 'pvn/subcommands/base/options'

module PVN::Subcommands::Log
  DEFAULT_LIMIT = 5

  class LimitOption < PVN::FixnumOption
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
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

  class UserOption < PVN::Option
    def initialize optargs = Hash.new
      super :user, '-u', "show only changes for the given user", nil, :as_cmdline_option => nil
    end
  end

  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :revision, PVN::MultipleRevisionsRegexpOption, [ :unsets => :limit ]
    has_option :format,   FormatOption
    has_option :help,     PVN::Subcommands::Base::HelpOption
    has_option :limit,    LimitOption
    has_option :user,     UserOption
    has_option :verbose,  PVN::BooleanOption, [ :verbose, '-v', [ "include the files in the change" ], false ]
    
    def paths
      unprocessed
    end
  end
end
