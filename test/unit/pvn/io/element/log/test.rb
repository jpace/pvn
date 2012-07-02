#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/log/tc'
require 'svnx/log/log'
require 'svnx/log/xml/xmllog'
require 'svnx/log/tc'
require 'pvn/io/element'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  module IOxxx
    class ElementLogTestCase < PVN::Log::TestCase
      # include Loggable
      
      def test_no_options
        dir = PVN::IOxxx::Element.new :filename => '.'
        logoptions = [ '--xml', '.' ]

        return if true

        dirlog = dir.log logoptions
        dirlog.entries.each do |entry|
          info "entry: #{entry}"
        end
     end
    end
  end
end
