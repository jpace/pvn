#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/option'

module PVN
  class OptionSet
    include Loggable

    # maps from the option set class to the valid options for that class.
    @@options_for_class = Hash.new { |h, k| h[k] = Array.new }

    attr_reader :unprocessed
    
    class << self
      def has_option name, optcls, optargs = Hash.new
        attr_reader name

        @@options_for_class[self] << { :name => name, :class => optcls, :args => optargs }

        define_method name do
          instance_eval do
            meth = name
            opt  = instance_variable_get '@' + name.to_s
            opt.value
          end
        end
      end
    end

    attr_reader :options
    attr_reader :arguments
    
    def initialize options = Array.new
      @options = options
      @arguments = Array.new

      opts = @@options_for_class[self.class]

      opts.each do |option|
        name = option[:name]
        cls  = option[:class]
        args = option[:args]
        opt  = cls.new(*args)
        add opt
        instance_variable_set '@' + name.to_s, opt
      end
    end

    def inspect
      @options.collect { |opt| opt.inspect }.join("\n")
    end

    def find_by_name name
      @options.find { |opt| opt.name == name }
    end

    def has_option? name
      find_by_name name
    end

    def to_command_line
      cmdline = Array.new
      @options.each do |opt|
        if cl = opt.to_command_line
          cmdline.concat cl
        end
      end
      cmdline
    end

    def unset key
      opt = find_by_name key
      opt && opt.unset
    end

    def process args
      options_processed = Array.new

      @unprocessed = args
      
      while !@unprocessed.empty?
        processed = false
        options.each do |opt|
          if opt.process @unprocessed
            processed = true
            options_processed << opt
          end
        end

        break unless processed
      end

      options_processed.each do |opt|
        opt.post_process self, @unprocessed
      end
    end

    def << option
      @options << option
    end

    def add option
      @options << option
      option
    end

    def as_command_line
      to_command_line + arguments
    end
  end
end
