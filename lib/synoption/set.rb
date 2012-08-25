#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'synoption/option'

module PVN
  class OptionSet
    include Loggable

    attr_reader :options
    attr_reader :arguments
    
    def initialize options = Array.new
      @options = options
      @arguments = Array.new
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

    def set_options_by_keys args
      args.each do |key, val|
        if opt = find_by_name(key)
          opt.set_value val
        end
      end
    end

    def match_option opt, args
      arg = args[0]

      match_type = opt.match_type? arg
      info "match_type: #{match_type}".cyan
      case match_type
      when :exact
        [ :set, opt.takes_value? ? 1 : 0 ]
      when :regexp
        [ :set, 0 ]
      when :negative
        [ :unset, 0 ]
      else
        nil
      end
    end    

    def set_options_from_args cmdobj, cmdargs
      @arguments = cmdargs.dup
      allargs = cmdargs.dup
      options_to_set = Array.new

      info "@arguments: #{@arguments}"

      processed = true
      cidx = 0
      while true
        processed = false
        @options.each do |opt|
          if na = match_option(opt, @arguments)
            type = na[0]
            nargs = na[1]
            options_to_set << [ opt, cidx, type, @arguments[nargs] ]
            cidx += na[1].size
            @arguments.slice! 0, nargs + 1
            processed = true
            break
          end
        end
        break unless processed
      end

      info "@arguments: #{@arguments}"

      options_to_set.each do |optentry|
        info "optentry: #{optentry}"
        opt  = optentry[0]
        idx  = optentry[1]
        type = optentry[2]
        optargs = optentry[3]

        if type == :set
          opt.set self, cmdobj, [ optargs ]
        elsif type == :unset
          opt.unset
        end
      end
    end
    
    def unset key
      opt = find_by_name key
      opt && opt.unset
    end

    def process obj, optargs, cmdargs
      set_options_by_keys optargs
      set_options_from_args obj, cmdargs

      info "cmdargs: #{cmdargs}"

      self
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
