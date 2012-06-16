#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/option/set'
require 'pvn/option/option'
require 'pvn/option/boolopt'
require 'pvn/option/revreopt'

module PVN
  DEFAULT_LIMIT = 5

  class LimitOption < Option
    def initialize lmtargs = Hash.new
      super :limit, '-l', "the number of log entries", :default => DEFAULT_LIMIT, :negate => [ %r{^--no-?limit} ]
    end
  end

  class VerboseOption < BooleanOption
    def initialize optargs = Hash.new
      super :verbose, '-v', [ "include the files in the change" ], :default => false
    end
  end

  class FormatOption < BooleanOption
    def initialize optargs = Hash.new
      super :format, '-f', "use the custom (colorized) format", :default => true, :negate => [ '-F', %r{^--no-?format} ], :as_svn_option => nil
    end
  end

  class LogOptionSet < OptionSet
    attr_accessor :revision
    attr_reader :format
    
    def initialize
      super

      add LimitOption.new
      @revision = add RevisionRegexpOption.new(:unsets => :limit)
      @verbose  = add VerboseOption.new
      @format   = add FormatOption.new
    end
  end
end