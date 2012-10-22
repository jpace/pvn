#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/revision_regexp_option'
require 'pvn/command/options'

module PVN::Seek
  class MatchOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      opts = Hash.new
      opts[:negate] = '--nomatch', '-M'
      super :match, '-m', 'find where the pattern matched', true, opts
    end
  end

  class RemovedOption < PVN::BooleanOption
    def initialize optargs = Hash.new
      opts = Hash.new
      super :removed, '-M', 'find where the pattern did not match', false, opts
    end
  end

  class OptionSet < PVN::Command::OptionSet
    has_option :revision, PVN::RevisionRegexpOption
    # has_option :match,    MatchOption
    has_option :removed,  RemovedOption
    has_option :help,     PVN::Command::HelpOption
  end
end
