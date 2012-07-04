#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/entries'
require 'svnx/log/xml/xmllog'
require 'svnx/log/tc'
require 'pvn/io/element'

module PVN
  module IOxxx
    class ElementLogTestCase < PVN::Log::TestCase
      # include Loggable
      
      def test_no_options
        dir = PVN::IOxxx::Element.new :local => '/Programs/wiquery/trunk'
        logoptions = Hash.new

        dirlog = dir.log logoptions
        # info "dirlog: #{dirlog}".yellow
        dirlog.entries.each do |entry|
          # info "entry: #{entry}".blue
        end
     end
    end
  end
end
