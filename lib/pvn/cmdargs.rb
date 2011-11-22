#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/options'

module PVN
  class OptionEntry
    include Loggable
    
    attr_reader :key
    attr_reader :tag
    attr_reader :options
    attr_reader :value

    class << self
      alias_method :new_orig, :new
      
      def new key, tag, options
        cls = options && options[:multiple] ? MultiValueOptionEntry : OptionEntry
        cls.new_orig key, tag, options
      end
    end

    def initialize key, tag, options
      @key = key
      @tag = tag
      @options = options
      @value = nil
    end

    def to_s
      "#{@key} (#{@tag}) #{@options.inspect} => #{@value}"
    end

    def set val
      if @options && @options[:multiple]
        @value << val
      else
        @value = val
      end
    end
  end

  class MultiValueOptionEntry < OptionEntry
    def initialize key, tag, options
      super
      info "options: #{options}"
      @value = Array.new
    end

    def set val
      @value << val
    end
  end

  class OptionSet
    include Loggable
    
    def initialize options = Array.new
      @options = Hash.new
      options.each do |opt|
        add_option opt
      end
      info "options: #{@options}".red
    end

    def has_key? key
      entry_for_key key
    end

    def entry_for_key key
      @options.values.detect { |ka| ka.key == key }
    end

    def add_option option
      key = option.name
      tag = option.tag
      opts = option.options.dup

      info "opts: #{opts}"

      defval = val = opts[:default]

      if defval
        # interpret the type and setter based on the default type
        if val.class == Fixnum  # no, we're not handling Bignum
          opts[:setter] ||= :next_argument_as_integer
          opts[:type]   ||= :integer
        end        
      end

      @options[option] = OptionEntry.new(key, tag, opts)
      info "options: #{@options}"

      if defval
        set_arg key, defval
      end
    end

    def create_entry option
      key = option.name
      tag = option.tag
      opts = option.options.dup

      info "opts: #{opts}"

      defval = val = opts[:default]

      if defval
        # interpret the type and setter based on the default type
        if val.class == Fixnum  # no, we're not handling Bignum
          opts[:setter] ||= :next_argument_as_integer
          opts[:type]   ||= :integer
        end        
      end

      @options[option] = OptionEntry.new(key, tag, opts)
      info "options: #{@options}"

      if defval
        entry.set defval
      end
    end

    def to_s
      to_a.join(' ')
    end

    def to_a
      array = Array.new
      @options.values.each do |entry|
        if entry.value
          array << entry.tag << entry.value.to_s
        end
      end
      array
    end

    def set_from_proc key, args, proc
      set_arg key, proc.call(args)
    end

    def set_arg key, val
      entry_for_key(key).set val
    end

    def unset_arg key
      set_arg key, nil
    end

    def process obj, args
      arg = args[0]
      info "arg: #{arg}"
      info "arg: #{arg.class}"
      info "args: #{args}"
      @options.each do |option, entry|
        info "option: #{option}".on_blue
        info "entry: #{entry}".on_blue
        if option.exact_match? arg
          args.shift
          return _set_arg obj, entry, args
        elsif option.regexp_match? arg
          info "arg: #{arg}"
          # args.shift
          return _set_arg obj, entry, args
        elsif option.negative_match? arg
          args.shift
          info "matched negative: #{entry.key}"
          unset_arg entry.key
          return true
        end
      end
      nil
    end
    
    def _set_arg obj, entry, args
      return nil unless entry

      info "entry: #{entry}".on_black

      if setter = entry.options[:setter]
        info "setter: #{setter}".on_black
        set_arg entry.key, setter.to_proc.call(obj, self, args)
      else
        set_arg entry.key, true
      end

      if unsets = entry.options[:unsets]
        info "unsets: #{unsets}".on_green
        unset_arg unsets
      end
      true
    end
  end
end
