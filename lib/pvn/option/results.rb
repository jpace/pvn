#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class OptionsResults
    include Loggable

    attr_reader :options
    
    def initialize options = Array.new
      @options = Array.new
      options.each do |opt|
        add_option opt
      end
      debug "options: #{@options}"
    end

    def has_option? name
      option_for_name name
    end

    def option_for_name name
      @options.detect { |opt| opt.name == name }
    end

    def add_option option
      @options << option
    end

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def to_s
      values.join(' ')
    end

    def values
      vals = Array.new
      @options.each do |opt|
        if opt.entry.value
          vals << opt.tag << opt.entry.value.to_s
        end
      end
      vals
    end

    def to_a
      values
    end

    def set_arg key, val
      opt = option_for_name key
      opt && opt.set_value(val)
    end

    def unset_arg key
      set_arg key, nil
    end

    def process cmdobj, args
      arg = args[0]
      @options.each do |opt|
        if opt.process(self, cmdobj, args)
          return true
        end
      end
      nil
    end    
  end
end
