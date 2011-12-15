#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/option/set'
require 'pvn/option/option'
require 'pvn/cmddoc'

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

          RIEL::Log.debug "self: #{self}"
          RIEL::Log.debug "opt: #{opt.inspect}"
          RIEL::Log.debug "@option_set: #{@option_set.inspect}"

          @doc.options << opt
        end
      end

      def find_option optname
        self.instance_eval do 
          @option_set.find_by_name optname
        end
      end

      def doc
        @doc ||= CommandDoc.new
        yield @doc if block_given?
        @doc
      end
      
      def options
        self.instance_eval do
          @option_set ||= OptionSet.new
          RIEL::Log.debug "@option_set: #{@option_set}"
          yield @option_set if block_given?
          @option_set
        end
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
