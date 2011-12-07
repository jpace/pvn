#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

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
      @value = val
    end
  end

  class MultiValueOptionEntry < OptionEntry
    def initialize key, tag, options
      super
      info "options: #{options}"
    end

    def set val
      (@value ||= Array.new) << val
    end
  end
end
