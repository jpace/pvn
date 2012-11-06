#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/multiple_revisions_option'
require 'pvn/command/options'

module PVN::Pct
  class OptionSet < PVN::Command::OptionSet
    has_option :revision, PVN::MultipleRevisionsRegexpOption
  end
end
