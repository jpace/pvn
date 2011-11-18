#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class CommandEntry
    attr_reader :key
    attr_reader :tag
    attr_reader :options
    attr_reader :value

    def initialize key, tag, options
      @key = key
      @tag = tag
      @options = options
      @value = nil
    end

    def to_s
      "#{@key} (#{@tag}) #{@options.inspect}"
    end
  end

  class CommandArgs
    include Loggable
    
    def initialize fromargs = Hash.new
      @known_args = Array.new
      @args = Hash.new
      @args.merge! fromargs
      info "args: #{@args}".red
      info "known_args: #{@known_args}".red
    end

    def has_key? key
      @known_args.detect { |ka| ka.key == key }
    end

    def key_for_tag tag
      info "tag: #{tag}".green
      @known_args.each do |entry|
        info "entry: #{entry}".green
        
        if entry.tag == tag
          return entry.key
        elsif entry.options && entry.options[:negate] && entry.options[:negate].select { |x| x.match(tag) }
          info "matched negative: #{entry.key}"
          return entry.key
        end
      end
      nil
    end

    def add_known_arg key, tag, options
      @known_args << CommandEntry.new(key, tag, options)
      info "known_args: #{@known_args}"
      if options[:default]
        set_arg key, options[:default]
      end
    end

    def to_s
      to_a.join(' ')
    end

    def to_a
      array = Array.new
      @known_args.each do |entry|
        if @args[entry.key]
          array << entry.tag << @args[entry.key].to_s
        end
      end
      array
    end

    def set_from_proc key, args, proc
      set_arg key, proc.call(args)
    end

    def set_arg key, val
      @args[key] = val
      info "args: #{@args}"
      info "known_args: #{@known_args}"
    end

    def unset_arg key
      set_arg key, nil
    end

    def process obj, arg, otherargs
      info "arg: #{arg}"
      info "arg: #{arg.class}"
      info "otherargs: #{otherargs}".on_blue
      @known_args.each do |entry|
        info "entry: #{entry}"
        if entry.tag == arg
          return _set_arg obj, entry, otherargs
        elsif entry.options && entry.options[:negate] && entry.options[:negate].detect { |x| info "x: #{x}".magenta; x.match(arg) }
          info "matched negative: #{entry.key}".on_red
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
