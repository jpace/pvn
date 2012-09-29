#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/boolean_option'
require 'pvn/revision/multiple_revisions_option'
require 'pvn/revision/base_option'
require 'pvn/command/options'

module PVN::Subcommands::Diff
  class WhitespaceOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :whitespace, '-w', 'ignore all whitespace', false
    end
  end

  # a change option is like a revision option, just against the previous
  # revision
  class ChangeOption < PVN::BaseRevisionOption
    def initialize optargs = Hash.new
      super :change, '-c', 'use the given revision against the previous one', nil
    end
  end

  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :revision,   PVN::MultipleRevisionsRegexpOption
    has_option :change,     ChangeOption
    has_option :whitespace, WhitespaceOption
    has_option :help,       PVN::Subcommands::Base::HelpOption
  end
end
