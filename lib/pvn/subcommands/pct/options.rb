#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/revision/multiple_revisions_option'
require 'pvn/subcommands/base/options'

module PVN::Subcommands::Pct
  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :revision, PVN::MultipleRevisionsRegexpOption
    has_option :help,     PVN::Subcommands::Base::HelpOption
  end
end
