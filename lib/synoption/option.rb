#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/doc'
require 'synoption/match'

module PVN
  class Option
    include Loggable
    
    attr_reader :name
    attr_reader :tag
    attr_reader :description

    attr_reader :options

    attr_reader :setter

    attr_reader :negate

    def initialize name, tag, description, options = Hash.new
      @name = name
      @tag = tag
      @description = description

      @options = options

      defval = options[:default]

      @setter = options[:setter]

      # interpret the type and setter based on the default type
      if @setter.nil? && defval && defval.class == Fixnum  # no, we're not handling Bignum
        @setter = :next_argument_as_integer
      end

      @value = defval

      @exact_matcher = OptionExactMatch.new self
      @negative_matcher = options[:negate] && OptionNegativeMatch.new(self, options[:negate])      
      @regexp_matcher = options[:regexp] && OptionRegexpMatch.new(self, options[:regexp])
    end

    def takes_value?
      true
    end

    def to_command_line
      return nil unless value
      
      if @options.include? :as_cmdline_option
        @options[:as_cmdline_option]
      else
        [ tag, value ]
      end
    end

    def to_s
      [ @name, @tag, @options ].join(", ")
    end

    def exact_match? arg
      @exact_matcher.match? arg
    end

    def negative_match? arg
      @negative_matcher and @negative_matcher.match? arg
    end

    def regexp_match? arg
      @regexp_matcher and @regexp_matcher.match? arg
    end

    def match_type? arg
      return nil unless arg

      if arg == tag || arg == '--' + @name.to_s
        :exact
      elsif @options[:negate] && @options[:negate].detect { |x| arg.index(x) }
        :negate
      elsif @options[:regexp] && @options[:regexp].match(arg)
        :regexp
      else
        nil
      end
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

      if @setter
        info "setter: #{@setter}"
        info "setter.to_proc: #{@setter.to_proc}"
        # setters are class methods:
        setter_proc = @setter.to_proc
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
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end
  end
end
