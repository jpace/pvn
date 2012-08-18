#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/doc'

module PVN
  class Option
    include Loggable
    
    attr_reader :name
    attr_reader :tag
    attr_reader :description

    attr_reader :options

    attr_reader :setter

    attr_reader :negate
    attr_reader :as_svn_option

    def initialize name, tag, description, options = Hash.new
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

      if defval
        @value = defval
      end
    end

    def takes_value?
      true
    end

    def has_svn_option?
      @options.include? :as_svn_option && @options[:as_svn_option]
    end

    def to_command_line
      return nil unless value
      
      if @options.include? :as_svn_option
        @options[:as_svn_option]
      else
        [ tag, value ]
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
      arg && @options && @options[:negate] && @options[:negate].detect { |x| arg.index(x) }
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
      debug "self: #{self}"
      debug "args: #{args}"

      if setter = @options[:setter]
        info "setter: #{setter}"
        info "setter.to_proc: #{setter.to_proc}"
        # setters are class methods:
        setter_proc = setter.to_proc
        @value = setter_proc.call cmdobj.class, optset, args
      else
        @value = true
      end

      if unsets = @options[:unsets]
        debug "unsets: #{unsets}"
        optset.unset unsets
      end
      true
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end
  end
end
