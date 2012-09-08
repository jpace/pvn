#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/base/options'

module PVN::Subcommands::Status
  class FormatOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      super :format, '-f', "use the custom (colorized) format", true, :negate => [ '-F', %r{^--no-?format} ], :as_cmdline_option => nil
    end
  end

  class OptionSet < PVN::Subcommands::Base::OptionSet
    has_option :format,   FormatOption
    has_option :help,     PVN::Subcommands::Base::HelpOption
    
    def paths
      unprocessed
    end
  end
end
