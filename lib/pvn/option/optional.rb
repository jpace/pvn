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
        RIEL::Log.debug "self: #{self}"
        RIEL::Log.debug "optname: #{optname}"

        self.instance_eval do 
          @option_set ||= OptionSet.new
          opt = Option.new optname, tag, desc, args
          @option_set.options << opt

          RIEL::Log.debug "self: #{self}".on_red
          RIEL::Log.debug "opt: #{opt.inspect}".on_red
          RIEL::Log.debug "@option_set: #{@option_set.inspect}".on_red

          @doc ||= Documenter.new
          @doc.options << opt
        end
      end

      def find_option optname
        self.instance_eval do 
          @option_set.find_by_name optname
        end
      end

      def args_to_option_results args
        RIEL::Log.debug "self: #{self}"
        RIEL::Log.debug "args: #{args}".on_red

        self.instance_eval do
          @option_set.results args
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

      def doc
        @doc ||= Documenter.new
        yield @doc if block_given?
      end
      
      def options
        @option_set ||= OptionSet.new
        yield @option_set if block_given?
      end
      
      def to_doc io = $stdout
        self.instance_eval { @doc.to_doc io }
      end

      def next_argument_as_integer ca, cmdargs
        cmdargs.shift.to_i
      end
    end
  end
end
