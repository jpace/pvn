#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/cmdargs'
require 'pvn/documenter'

Log.level = Log::DEBUG

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
  end

  module Optional
    include Loggable

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      Log.info "self: #{self}"

      def has_option optname, tag, desc, args = Hash.new
        Log.info "self: #{self}"
        Log.info "optname: #{optname}"

        self.instance_eval do 
          opt = Option.new optname, tag, desc, args
          (@options ||= Array.new) << opt

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
          ca = CommandArgs.new @options
          args.each do |key, val|
            Log.info "key: #{key}; val: #{val}"
            if ca.has_key? key
              Log.info "key: #{key}; val: #{val}"
              ca.set_arg key, val
            end
          end
          ca
        end
      end

      [ :subcommands, :description, :usage, :summary ].each do |name|
        define_method name do |val|
          self.instance_eval do 
            @doc ||= Documenter.new
            meth = (name.to_s + '=').to_sym
            Log.info "sending #{meth} #{val}".cyan
            @doc.send meth, val
          end
        end
      end      

      [ :examples ].each do |name|
        define_method name do
          self.instance_eval do 
            @doc ||= Documenter.new
            Log.info "sending #{name}".red
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
