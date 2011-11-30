#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/set'
require 'pvn/option/option'
require 'pvn/documenter'

module PVN
  module Optional
    include Loggable

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def has_option optname, tag, desc, args = Hash.new
        RIEL::Log.info "self: #{self}"
        RIEL::Log.info "optname: #{optname}"

        self.instance_eval do 
          @option_set ||= OptionSet.new
          opt = Option.new optname, tag, desc, args
          (@options ||= Array.new) << opt

          RIEL::Log.info "self: #{self}".on_red
          RIEL::Log.info "opt: #{opt.inspect}".on_red
          RIEL::Log.info "@options: #{@options.inspect}".on_red

          @option_set.add_option opt

          RIEL::Log.info "@option_set: #{@option_set.inspect}".on_red

          @doc ||= Documenter.new
          @doc.options << opt
        end
      end

      def find_option optname
        self.instance_eval do 
          @options.find { |opt| opt.name == optname }
        end
      end

      def args_to_option_set args
        RIEL::Log.info "self: #{self}"
        RIEL::Log.info "args: #{args}".on_red

        self.instance_eval do
          optset = OptionSet.new @options
          args.each do |key, val|
            RIEL::Log.info "key: #{key}; val: #{val}"
            if optset.has_key? key
              RIEL::Log.info "key: #{key}; val: #{val}"
              optset.set_arg key, val
            end
          end
          optset
        end
      end

      def get_option_set
        RIEL::Log.info "self: #{self}"

        self.instance_eval do
          OptionSet.new @options
        end
      end

      def get_optset
        self.instance_eval do 
          @option_set
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
