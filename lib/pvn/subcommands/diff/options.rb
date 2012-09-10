#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/boolean_option'
require 'pvn/subcommands/revision/multiple_revisions_option'
require 'pvn/subcommands/base/options'

module PVN::Subcommands::Diff
  class WhitespaceOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :whitespace, '-w', 'ignore all whitespace', false
    end
  end

  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :revision,   PVN::MultipleRevisionsRegexpOption
    has_option :whitespace, WhitespaceOption
    has_option :help,       PVN::Subcommands::Base::HelpOption

    def name
      'diff'
    end
    
    def paths
      unprocessed
    end
  end
end
