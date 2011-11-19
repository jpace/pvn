#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/cmdargs'

Log.level = Log::DEBUG

module PVN
  module Optional
    include Loggable

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      Log.info "self: #{self}"

      def has_option optname, tag, args = Hash.new
        Log.info "self: #{self}"
        Log.info "optname: #{optname}"

        self.instance_eval { (@options ||= Array.new) << [ optname, tag, args ] }
      end

      def make_command_args args
        Log.info "self: #{self}"

        self.instance_eval do
          ca = CommandArgs.new
          @options.each do |opt|
            ca.add_known_arg(*opt)
          end
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
    end

    def next_argument_as_integer cmdargs
      cmdargs.shift.to_i
    end
  end
end
