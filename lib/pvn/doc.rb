#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

Log.level = Log::DEBUG

module PVN
  module Doc
    include Loggable

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def _save key, val
        Log.info "self: #{self}".on_blue
        Log.info "key: #{key}".on_blue
        Log.info "val: #{val}".on_blue
        self.instance_eval { (@doc ||= Hash.new)[key] = val }
      end

      [ :subcommands, :description, :usage, :summary, :examples ].each do |name|
        define_method name do |val|
          _save name, val
        end
      end
    end
  end
end
