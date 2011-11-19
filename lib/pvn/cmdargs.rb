#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/options'

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
    
    def initialize options
      @known_options = Array.new
      options.each do |opt|
        add_known_option opt
      end
      info "known_options: #{@known_options}".red
    end

    def has_key? key
      entry_for_key key
    end

    def entry_for_key key
      @known_options.detect { |ka| ka.key == key }
    end

    def key_for_tag tag
      info "tag: #{tag}"
      @known_options.each do |entry|
        if entry.match? tag
          return entry.key
        end
      end
      nil
    end

    def add_known_option opt
      key = opt.name
      tag = opt.tag
      opts = opt.options.dup

      info "opts: #{opts}"

      defval = val = opts[:default]

      if defval
        # interpret the type and setter based on the default type
        if val.class == Fixnum  # no, we're not handling Bignum
          opts[:setter] ||= :next_argument_as_integer
          opts[:type]   ||= :integer
        end        
      end

      @known_options << CommandEntry.new(key, tag, opts)
      info "known_options: #{@known_options}"

      if defval
        set_arg key, defval
      end
    end

    def to_s
      to_a.join(' ')
    end

    def to_a
      array = Array.new
      @known_options.each do |entry|
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
      @known_options.each do |entry|
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
