#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class OptionSet
    include Loggable

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
      option_for_name name
    end

    def option_for_name name
      @options.detect { |opt| opt.name == name }
    end

    def to_command_line
      cmdline = Array.new
      @options.each do |opt|
        cl = opt.to_command_line
        if cl
          cmdline.concat cl
        end
      end
      cmdline
    end

    def set_options_by_keys args
      args.each do |key, val|
        if opt = option_for_name(key)
          opt.set_value val
        end
      end
    end

    def match_option opt, args
      arg = args[0]
      debug "arg: #{arg}"
      debug "arg: #{arg.class}"

      debug "self: #{self}".red
      if opt.exact_match? arg
        debug "opt: #{opt}".red
        return [ :set, 1 ]
      elsif opt.regexp_match? arg
        debug "opt: #{opt}".yellow
        return [ :set, 0 ]
      elsif opt.negative_match? arg
        debug "opt: #{opt}".green
        return [ :unset, 0 ]
      end
      nil
    end    

    def set_options_from_args cmdobj, cmdargs
      allargs = cmdargs.dup
      options_to_set = Array.new

      processed = true
      cidx = 0
      while true
        info "cmdargs: #{cmdargs}".on_blue
        processed = false
        @options.each do |opt|
          info "opt: #{opt}"
          if na = match_option(opt, cmdargs)
            info "opt: #{opt}".yellow
            info "cidx: #{cidx}".yellow
            info "na: #{na}".yellow
            type = na[0]
            nargs = na[1]
            options_to_set << [ opt, cidx, type, cmdargs[nargs] ]
            cidx += na[1].size
            info "cidx: #{cidx}".yellow
            info "cmdargs: #{cmdargs}".on_blue
            cmdargs.slice!(0, nargs + 1)
            info "cmdargs: #{cmdargs}".on_blue
            processed = true
            break
          end
        end
        info "cmdargs: #{cmdargs}".on_blue
        break unless processed
      end

      options_to_set.each do |optentry|
        info "optentry: #{optentry}".yellow
      end

      unprocargs = cmdargs[cidx ... cmdargs.length]
      info "unprocargs: #{unprocargs}".yellow
      
      options_to_set.each do |optentry|
        info "optentry: #{optentry}".yellow
        
        opt = optentry[0]
        idx = optentry[1]
        type = optentry[2]
        args = optentry[3]

        info "  opt  : #{opt}".yellow
        info "  idx  : #{idx}".yellow
        info "  type : #{type}".yellow
        info "  args : #{args}".yellow

        if type == :set
          opt.set self, cmdobj, [ args ]
        elsif type == :unset
          opt.unset
        end
      end
    end
    
    def unset key
      opt = option_for_name key
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
  end
end
