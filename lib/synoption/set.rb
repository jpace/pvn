#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel/log/loggable'
require 'synoption/option'
require 'synoption/exception'

module PVN
  class OptionList    
    attr_reader :options
    
    def initialize options = Array.new
      @options = options
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

    def << option
      @options << option
    end

    def add option
      @options << option
      option
    end
  end

  class OptionSet < OptionList
    include RIEL::Loggable

    # maps from the option set class to the valid options for that class.
    @@options_for_class = Hash.new { |h, k| h[k] = Array.new }

    attr_reader :unprocessed

    def self.has_option name, optcls, optargs = Hash.new
      @@options_for_class[self] << { :name => name, :class => optcls, :args => optargs }

      define_method name do
        instance_eval do
          meth = name
          opt  = instance_variable_get '@' + name.to_s
          opt.value
        end
      end
    end

    attr_reader :options
    
    def initialize options = Array.new
      super 

      cls = self.class
      while cls != OptionSet
        add_options_for_class cls
        cls = cls.superclass
      end
    end

    def add_options_for_class cls
      opts = @@options_for_class[cls]

      opts.each do |option|
        name = option[:name]
        cls  = option[:class]
        args = option[:args]
        opt  = cls.new(*args)
        add opt
        instance_variable_set '@' + name.to_s, opt
      end
    end

    def unset key
      opt = find_by_name key
      opt && opt.unset
    end

    def process args
      options_processed = Array.new

      info "args: #{args}"
      @unprocessed = args
      info "@unprocessed: #{@unprocessed}"

      aborted = false
      
      while !@unprocessed.empty?
        if @unprocessed[0] == '--'
          @unprocessed.delete_at 0
          aborted = true
          break
        end

        processed = false

        options.each do |opt|
          if opt.process @unprocessed
            processed = true
            options_processed << opt
          end
        end

        break unless processed
      end

      unless aborted
        check_for_valid_options 
      end

      post_process_all options_processed
    end

    def check_for_valid_options 
      @unprocessed.each do |opt|
        if opt.start_with? '-'
          raise OptionException.new "error: option: #{opt} invalid for #{name}"
        end
      end
    end

    def post_process_all options_processed
      options_processed.each do |opt|
        opt.post_process self, @unprocessed
      end
    end
  end
end
