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

    def process obj, args
      arg = args[0]
      debug "arg: #{arg}"
      debug "arg: #{arg.class}"
      debug "args: #{args}"
      @options.each do |option, entry|
        debug "option: #{option}"
        debug "entry: #{entry}"
        if option.exact_match? arg
          args.shift
          return _set_arg obj, entry, args
        elsif option.regexp_match? arg
          debug "arg: #{arg}"
          return _set_arg obj, entry, args
        elsif option.negative_match? arg
          args.shift
          debug "matched negative: #{entry.key}"
          unset_arg entry.key
          return true
        end
      end
      nil
    end
    
    def _set_arg obj, entry, args
      return nil unless entry

      debug "entry: #{entry}".on_black

      if setter = entry.options[:setter]
        debug "setter: #{setter}".on_black
        set_entry entry, setter.to_proc.call(obj.class, self, args)
      else
        set_entry entry, true
      end

      if unsets = entry.options[:unsets]
        debug "unsets: #{unsets}".on_green
        unset_arg unsets
      end
      true
    end
  end
end
