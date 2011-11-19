#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/cmdargs'

Log.level = Log::DEBUG

module PVN
  module Optional
    include Loggable

    @@options = Hash.new { |h, k| h[k] = Array.new }

    def has_option optname, tag, args = Hash.new
      Log.info "self: #{self}".on_magenta
      Log.info "optname: #{optname}".on_magenta

      @@options[self] << [ optname, tag, args ]

      Log.info "options: #{@@options}".on_magenta
    end

    def make_command_args args
      ca = CommandArgs.new
      @@options[self].each do |opt|
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

    def get_next_argument_as_integer cmdargs
      cmdargs.shift.to_i
    end
  end
end
