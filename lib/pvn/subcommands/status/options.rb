#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/base/options'
require 'pvn/subcommands/base/color_option'

module PVN::Subcommands::Status
  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :color,    PVN::Subcommands::Base::ColorOption
    has_option :help,     PVN::Subcommands::Base::HelpOption
  end
end
