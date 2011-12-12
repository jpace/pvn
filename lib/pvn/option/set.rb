#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/results'
require 'pvn/option/entry'

module PVN
  class OptionSet
    include Loggable

    attr_reader :options
    
    def initialize options = Array.new
      @options = options
    end

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def find_by_name name
      @options.find { |opt| opt.name == name }
    end

    def results args
      optresult = OptionsResults.new @options
      args.each do |key, val|
        RIEL::Log.debug "key: #{key}; val: #{val}"
        if optresult.has_key? key
          RIEL::Log.debug "key: #{key}; val: #{val}"
          optresult.set_arg key, val
        end
      end
      optresult
    end

    def <<(option)
      @options << option
    end
  end
end
