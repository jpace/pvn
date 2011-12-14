#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/entry'

module PVN
  class Option
    include Loggable
    
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :options
    attr_accessor :description
    attr_accessor :entry

    def initialize name, tag, description, options
      @name = name
      @tag = tag
      @description = description
      @options = options

      defval = options[:default]

      # interpret the type and setter based on the default type
      if defval && defval.class == Fixnum  # no, we're not handling Bignum
        @options[:setter] ||= :next_argument_as_integer
        @options[:type]   ||= :integer
      end

      @entry = OptionEntry.new @name, @tag, @options
      # debug "options: #{@options}"

      if defval
        @entry.set defval
      end
    end

    def to_s
      [ @name, @tag, @options ].join(", ")
    end

    def match? arg
      exact_match?(arg) || negative_match?(arg) || regexp_match?(arg)
    end

    def exact_match? arg
      arg == tag || arg == '--' + @name.to_s
    end

    def negative_match? arg
      @options && @options[:negate] && @options[:negate].detect { |x| x.match(arg) }
    end

    def regexp_match? arg
      options[:regexp] && options[:regexp].match(arg)
    end

    def process results, cmdobj, args
      arg = args[0]
      debug "arg: #{arg}".magenta
      debug "arg: #{arg.class}"
      debug "args: #{args}"

      debug "self: #{self}"
      if (exact_match?(arg) && (args.shift || true)) ||
          regexp_match?(arg)
        info "option: #{self}".on_blue
        info "option.class: #{self.class}".on_blue
        set results, cmdobj, args
        return true
      elsif negative_match? arg
        args.shift
        unset
        return true
      end
      nil
    end    

    def unset
      @entry.set nil
    end

    def set_value val
      @entry.set val
    end

    def set results, cmdobj, args
      debug "self: #{self}".on_black

      if setter = @options[:setter]
        info "setter: #{setter}".on_black
        info "setter.to_proc: #{setter.to_proc}".on_black
        # setters are class methods:
        setter_proc = setter.to_proc
        val = setter_proc.call cmdobj.class, results, args
        @entry.set val
      else
        @entry.set true
      end

      if unsets = @options[:unsets]
        debug "unsets: #{unsets}".on_green
        results.unset_arg unsets
      end
      true
    end
  end
end
