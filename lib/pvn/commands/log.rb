#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn/commands/cachecmd'

module PVN

  module Log
    class Entry
      attr_reader :revision
      attr_reader :user
      attr_reader :date
      attr_reader :time
      attr_reader :tz
      attr_reader :dtg
      attr_reader :nlines
      attr_reader :files
      attr_reader :comment

      def set_from_args name, args
        puts "name: #{name.inspect}"
        self.instance_variable_set '@' + name.to_s, args[name]
      end

      def initialize args = Hash.new
        @revision = args[:revision]
        @user = args[:user]
        set_from_args :date, args
      end
    end

    class Command < CachableCommand
      # 
    end
  end
end
