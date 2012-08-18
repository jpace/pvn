#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/doc'
require 'synoption/match'
require 'synoption/base_option'

module PVN
  class Option < BaseOption
    include Loggable

    attr_reader :setter

    def initialize name, tag, description, options = Hash.new
      super
      
      @setter = options[:setter]

      # interpret the type and setter based on the default type
      if @setter.nil? && default && default.class == Fixnum  # no, we're not handling Bignum
        @setter = :next_argument_as_integer
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
  end
end
