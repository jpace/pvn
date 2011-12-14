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

    def set_arg results, cmdobj, args
      debug "self: #{self}".on_black

      if setter = @options[:setter]
        info "setter: #{setter}".on_black
        info "setter.to_proc: #{setter.to_proc}".on_black
        # setters are class methods:
        setter_proc = setter.to_proc
        val = setter_proc.call cmdobj.class, results, args
        set val
      else
        set true
      end

      if unsets = @options[:unsets]
        debug "unsets: #{unsets}".on_green
        results.unset_arg unsets
      end
      true
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
