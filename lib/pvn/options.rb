#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/cmdargs'
require 'pvn/documenter'

Log.level = Log::DEBUG
Log.set_widths(-15, 5, -35)

module PVN
  class Option
    attr_accessor :name
    attr_accessor :tag
    attr_accessor :options
    attr_accessor :description

    def initialize name, tag, description, options
      @name = name
      @tag = tag
      @description = description
      @options = options
    end

    def to_s
      [ @name, @tag, @options ].join(", ")
    end

    def match? arg
      exact_match?(arg) || negative_match?(arg) || regexp_match?(arg)
    end

    def exact_match? arg
      arg == tag || arg == '--' + @name.to_s
    end

    def negative_match? arg
      @options && @options[:negate] && @options[:negate].detect { |x| x.match(arg) }
    end

    def regexp_match? arg
      options[:regexp] && options[:regexp].match(arg)
    end
  end

  module Optional
    include Loggable

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def has_option optname, tag, desc, args = Hash.new
        Log.info "self: #{self}"
        Log.info "optname: #{optname}"

        self.instance_eval do 
          @option_set ||= OptionSet.new
          opt = Option.new optname, tag, desc, args
          (@options ||= Array.new) << opt
          @option_set.add_option opt

          @doc ||= Documenter.new
          @doc.options << opt
        end
      end

      def find_option optname
        self.instance_eval do 
          @options.find { |opt| opt.name == optname }
        end
      end

      def make_command_args args
        Log.info "self: #{self}"

        self.instance_eval do
          optset = OptionSet.new @options
          args.each do |key, val|
            Log.info "key: #{key}; val: #{val}"
            if optset.has_key? key
              Log.info "key: #{key}; val: #{val}"
              optset.set_arg key, val
            end
          end
          optset
        end
      end

      [ :subcommands, :description, :usage, :summary ].each do |name|
        define_method name do |val|
          self.instance_eval do 
            @doc ||= Documenter.new
            meth = (name.to_s + '=').to_sym
            @doc.send meth, val
          end
        end
      end      

      [ :examples ].each do |name|
        define_method name do
          self.instance_eval do 
            @doc ||= Documenter.new
            @doc.send name
          end
        end
      end
      
      def to_doc io = $stdout
        self.instance_eval { @doc.to_doc io }
      end
    end

    def next_argument_as_integer ca, cmdargs
      cmdargs.shift.to_i
    end
  end
end
