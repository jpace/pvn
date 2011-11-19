#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class CommandEntry
    attr_reader :key
    attr_reader :tag
    attr_reader :options
    attr_accessor :value

    def initialize key, tag, options
      @key = key
      @tag = tag
      @options = options
      @value = nil
    end

    def to_s
      "#{@key} (#{@tag}) #{@options.inspect} => #{@value}"
    end

    def match? arg
      exact_match?(arg) || negative_match?(arg)
    end

    def exact_match? arg
      tag == arg
    end

    def negative_match? arg
      @options && @options[:negate] && @options[:negate].detect { |x| x.match(arg) }
    end
  end

  class CommandArgs
    include Loggable
    
    def initialize fromargs = Hash.new
      @known_args = Array.new
      fromargs.each do |key, value|
        if entry = entry_for_key(key)
          entry.value = value
        end
      end
      info "known_args: #{@known_args}".red
    end

    def has_key? key
      entry_for_key key
    end

    def entry_for_key key
      @known_args.detect { |ka| ka.key == key }
    end

    def key_for_tag tag
      info "tag: #{tag}".green
      @known_args.each do |entry|
        info "entry: #{entry}".green
        if entry.match? tag
          return entry.key
        end
      end
      nil
    end

    def add_known_arg key, tag, options
      opts = options.dup

      info "opts: #{opts}"

      defval = val = opts[:default]

      if defval
        # interpret the type and setter based on the default type
        if val.class == Fixnum  # no, we're not handling Bignum
          opts[:setter] ||= :next_argument_as_integer
          opts[:type]   ||= :integer
        end        
      end

      @known_args << CommandEntry.new(key, tag, opts)
      info "known_args: #{@known_args}"

      if defval
        set_arg key, options[:default]
      end
    end

    def to_s
      to_a.join(' ')
    end

    def to_a
      array = Array.new
      @known_args.each do |entry|
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
      entry_for_key(key).value = val
    end

    def unset_arg key
      set_arg key, nil
    end

    def process obj, arg, otherargs
      info "arg: #{arg}"
      info "arg: #{arg.class}"
      info "otherargs: #{otherargs}"
      @known_args.each do |entry|
        info "entry: #{entry}"
        if entry.exact_match? arg
          return _set_arg obj, entry, otherargs
        elsif entry.negative_match? arg
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
        set_arg entry.key, setter.to_proc.call(obj, args)
      end
      true
    end
  end
end
