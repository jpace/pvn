#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class OptionsResults
    include Loggable

    attr_reader :options
    
    def initialize options = Array.new
      @options = Array.new
      options.each do |opt|
        add_option opt
      end
      debug "options: #{@options}"
    end

    def option_for_name name
      @options.detect { |opt| opt.name == name }
    end

    def add_option option
      @options << option
    end

    def to_s
      values.join(' ')
    end

    def values
      vals = Array.new
      @options.each do |opt|
        if opt.value
          vals << opt.tag << opt.value.to_s
        end
      end
      vals
    end

    def to_a
      values
    end

    def unset_arg key
      opt = option_for_name key
      opt && opt.unset
    end

    def process cmdobj, args
      @options.each do |opt|
        if opt.process(self, cmdobj, args)
          return true
        end
      end
      nil
    end    
  end
end
