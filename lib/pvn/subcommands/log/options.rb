#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/fixnum_option'
require 'synoption/boolean_option'
require 'pvn/subcommands/revision/multiple_revisions_option'
require 'pvn/subcommands/base/options'
require 'pvn/subcommands/base/color_option'

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

  class UserOption < PVN::Option
    def initialize optargs = Hash.new
      super :user, '-u', "show only changes for the given user", nil, :as_cmdline_option => nil
    end
  end

  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :revision, PVN::MultipleRevisionsRegexpOption, [ :unsets => :limit ]
    has_option :color,    PVN::Subcommands::Base::ColorOption
    has_option :help,     PVN::Subcommands::Base::HelpOption
    has_option :limit,    LimitOption
    has_option :user,     UserOption
    has_option :verbose,  PVN::BooleanOption, [ :verbose, '-v', [ "include the files in the change" ], false ]

    def name
      'log'
    end
    
    def paths
      unprocessed
    end
  end
end
