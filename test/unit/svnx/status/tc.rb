#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'

module SVNx
  module Status
    class TestCase < PVN::TestCase
      include Loggable

      def assert_entry_equals entry, expdata
        info "entry: #{entry.inspect}"
        info "expdata: #{expdata.inspect}"

        [ :path, :status ].each do |field|
          assert_equal expdata[field], entry.send(field)
        end
      end
    end
  end
end
