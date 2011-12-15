#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

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

    def values
      vals = Array.new
      @options.each do |opt|
        if opt.value
          vals << opt.tag << opt.value.to_s
        end
      end
      vals
    end

    def set_options_by_keys args
      args.each do |key, val|
        if opt = option_for_name(key)
          opt.set_value val
        end
      end
    end

    def set_options_from_args cmdobj, cmdargs
      while cmdargs.length > 0
        processed = false
        @options.each do |opt|
          if opt.process(self, cmdobj, cmdargs)
            processed = true
            break
          end
        end

        return unless processed
      end
    end
    
    def unset key
      opt = option_for_name key
      opt && opt.unset
    end

    def process obj, optargs, cmdargs
      set_options_by_keys optargs
      set_options_from_args obj, cmdargs

      info "cmdargs: #{cmdargs}"

      self
    end

    def << option
      @options << option
    end
  end
end
