#!/usr/bin/ruby -w
# -*- ruby -*-

require 'synoption/boolean_option'
require 'pvn/revision/multiple_revisions_option'
require 'pvn/revision/base_option'
require 'pvn/command/options'

module PVN::Diff
  class WhitespaceOption < Synoption::BooleanOption
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

  class OptionSet < PVN::Command::OptionSet
    has_option :revision,   PVN::MultipleRevisionsRegexpOption
    has_option :change,     ChangeOption
    has_option :whitespace, WhitespaceOption
  end
end
