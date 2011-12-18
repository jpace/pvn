#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class Option
    include Loggable
    
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :options
    attr_accessor :description

    def initialize *args
      if args.class == Hash
        initialize_from_hash args
      else
        name, tag, description, options = *args
        initialize_from_hash :name => name, :tag => tag, :description => description, :options => options
      end
    end

    def initialize_from_hash args
      @name = args[:name]
      @tag = args[:tag]
      @description = args[:description]
      @options = args[:options]
      @value = args[:value]

      defval = @options[:default]

      # interpret the type and setter based on the default type
      if defval && defval.class == Fixnum  # no, we're not handling Bignum
        @options[:setter] ||= :next_argument_as_integer
        @options[:type]   ||= :integer
      end

      if defval
        @value = defval
      end
    end

    def to_command_line
      value && [ tag, value ]
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
      @options[:regexp] && @options[:regexp].match(arg)
    end

    def unset
      @value = nil
    end

    def set_value val
      @value = val
    end

    def value
      @value
    end

    def set optset, cmdobj, args
      debug "self: #{self}".on_black
      debug "args: #{args}".on_black

      if setter = @options[:setter]
        info "setter: #{setter}".on_black
        info "setter.to_proc: #{setter.to_proc}".on_black
        # setters are class methods:
        setter_proc = setter.to_proc
        @value = setter_proc.call cmdobj.class, optset, args
      else
        @value = true
      end

      if unsets = @options[:unsets]
        debug "unsets: #{unsets}".on_green
        optset.unset unsets
      end
      true
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end
  end
end
