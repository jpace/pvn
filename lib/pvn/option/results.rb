#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/entry'

module PVN
  class OptionsResults
    include Loggable

    attr_reader :options
    
    def initialize options = Array.new
      @options = Hash.new
      options.each do |opt|
        add_option opt
      end
      debug "options: #{@options}"
    end

    def has_key? key
      entry_for_key key
    end

    def entry_for_key key
      @options.values.detect { |ka| ka.key == key }
    end

    def add_option option
      @options[option] = option.entry
    end

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def to_s
      values.join(' ')
    end

    def values
      vals = Array.new
      @options.values.each do |entry|
        if entry.value
          vals << entry.tag << entry.value.to_s
        end
      end
      vals
    end

    def to_a
      values
    end

    def set_arg key, val
      set_entry entry_for_key(key), val
    end

    def set_entry entry, val
      entry.set val
    end

    def unset_arg key
      set_arg key, nil
    end

    def unset_entry entry
      entry.set nil
    end

    def process cmdobj, args
      arg = args[0]
      debug "arg: #{arg}".magenta
      debug "arg: #{arg.class}"
      debug "args: #{args}"
      @options.keys.each do |option|
        debug "option: #{option}"
        if (option.exact_match?(arg) && (args.shift || true)) ||
            option.regexp_match?(arg)
          return option.set_arg self, cmdobj, args
        elsif option.negative_match? arg
          args.shift
          option.unset
          return true
        end
      end
      nil
    end    

    def _set_arg cmdobj, option, args
      option.set_arg self, cmdobj, args
    end
  end
end
