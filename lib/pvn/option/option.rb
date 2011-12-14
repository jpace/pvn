#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class Option
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

    def process results, obj, args
      return nil unless @entry

      debug "@entry: #{@entry}".on_black

      if setter = @entry.options[:setter]
        debug "setter: #{setter}".on_black
        @entry.set setter.to_proc.call(obj.class, results, args)
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
