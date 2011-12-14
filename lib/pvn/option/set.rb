#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/results'

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

    def results obj, args, cmdargs
      optresults = OptionsResults.new @options
      args.each do |key, val|
        if optresults.has_option? key
          optresults.set_arg key, val
        end
      end
      
      while cmdargs.length > 0
        unless optresults.process obj, cmdargs
          break
        end
      end

      info "optresults: #{optresults}"
      info "optresults.values: #{optresults.values.inspect}"
      info "cmdargs: #{cmdargs}"

      optresults
    end

    def << option
      @options << option
    end
  end
end
