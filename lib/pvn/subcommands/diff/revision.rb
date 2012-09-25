#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN::Subcommands::Diff
  # this will replace RevisionEntry
  class Revision
    include Loggable
    
    attr_reader :value
    attr_reader :from
    attr_reader :to

    def initialize from, to = nil
      if to
        @from = from
        @to = to
      else
        @from, @to = from.split(':')
      end
    end

    def to_s
      str = @from.to_s
      unless working_copy?
        str << ':' << @to.to_s
      end
      str
    end

    def head?
      @to == nil || @to == :head
    end

    def working_copy?
      @to == nil || @to == :wc || @to == :working_copy
    end
  end
end
