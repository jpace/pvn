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

    def has_option? name
      option_for_name name
    end

    def option_for_name name
      @options.detect { |opt| opt.name == name }
    end

    def set_options_by_keys optresults, args
      args.each do |key, val|
        if opt = option_for_name(key)
          opt.set_value val
        end
      end
    end

    def set_options_from_args optresults, cmdobj, cmdargs
      while cmdargs.length > 0
        processed = false
        @options.each do |opt|
          if opt.process(optresults, cmdobj, cmdargs)
            processed = true
            break
          end
        end

        return unless processed
      end
    end
    
    def process obj, optargs, cmdargs
      optresults = OptionsResults.new @options

      set_options_by_keys optresults, optargs
      set_options_from_args optresults, obj, cmdargs

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
