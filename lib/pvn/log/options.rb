#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/set'
require 'synoption/option'
require 'synoption/fixnum_option'
require 'synoption/boolean_option'
require 'pvn/revision/multiple_revisions_option'
require 'pvn/command/options'
require 'pvn/command/color_option'

module PVN::Log
  DEFAULT_LIMIT = 5

  class LimitOption < Synoption::FixnumOption
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end
  end

  class FilesOption < Synoption::BooleanOption
    def initialize optargs = Hash.new
      super :files, '-f', [ "list the files in the change" ], false
    end
  end

  class UserOption < Synoption::Option
    def initialize optargs = Hash.new
      super :user, '-u', "show only changes for the given user", nil, :as_cmdline_option => nil
    end
  end
  
  class OptionSet < PVN::Command::OptionSet
    has_option :revision, PVN::MultipleRevisionsRegexpOption, [ :unsets => :limit ]
    has_option :color,    PVN::Command::ColorOption
    has_option :limit,    LimitOption
    has_option :user,     UserOption
    has_option :files,    FilesOption
  end
end
