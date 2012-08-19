#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/doc'
require 'synoption/match'

module PVN
  class BaseOption
    include Loggable

    # for as_cmdline_option:
    NO_CMDLINE_OPTION = Object.new
    
    attr_reader :name
    attr_reader :tag
    attr_reader :description
    attr_reader :default

    attr_reader :negate
    attr_reader :regexp

    def initialize name, tag, description, default, options = Hash.new
      @name = name
      @tag = tag
      @description = description

      @value = @default = default

      @matchers = Hash.new
      @matchers[:exact] = OptionExactMatch.new @tag, @name
      if @negate = options[:negate]
        @matchers[:negative] = OptionNegativeMatch.new(@negate)
      end
      
      if @regexp = options[:regexp]
        @matchers[:regexp] = OptionRegexpMatch.new @regexp
      end
      
      if options.include? :as_cmdline_option
        if options[:as_cmdline_option].nil?
          @as_cmdline_option = NO_CMDLINE_OPTION
        else
          @as_cmdline_option = options[:as_cmdline_option]
        end
      else
        @as_cmdline_option = nil
      end
    end

    def takes_value?
      true
    end

    def to_command_line
      return nil unless value
      
      if @as_cmdline_option
        @as_cmdline_option == NO_CMDLINE_OPTION ? nil : @as_cmdline_option
      else
        [ tag, value ]
      end
    end

    def to_s
      [ @name, @tag ].join(", ")
    end

    def exact_match? arg
      @matchers[:exact].match? arg
    end

    def negative_match? arg
      @matchers[:negative] and @matchers[:negative].match? arg
    end

    def regexp_match? arg
      @matchers[:regexp] and @matchers[:regexp].match? arg
    end

    def match_type? arg
      return nil unless arg
      
      @matchers.each do |type, matcher|
        if matcher.match? arg
          return type
        end
      end

      nil
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
      
    def to_doc io
      doc = Doc.new self
      doc.to_doc io
    end
  end
end
