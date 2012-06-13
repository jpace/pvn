#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  module SVN
    class Entry
      include Loggable

      LOG_SUMMARY_RE = Regexp.new '^r(\d+) \| (\S+) \| (\S+) (\S+) (\S+) \((.*)\) \| (\d+) lines?$'

      attr_reader :revision, :user, :date, :time, :tz, :dtg, :nlines, :files, :comment
      
      def initialize args = Hash.new
        @revision = args[:revision]
        @user = args[:user]
        @date = args[:date]
        @time = args[:time]
        @tz = args[:tz]
        @dtg = args[:dtg]
        @nlines = args[:nlines]
        @files = args[:files]
        @comment = args[:comment]
      end
    end
  end
end
