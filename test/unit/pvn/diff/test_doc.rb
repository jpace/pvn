#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/diff/diffcmd'

module PVN
  class TestDiffDoc < Test::Unit::TestCase
    include Loggable

    def test_documentation
      strio = StringIO.new
      DiffCommand.to_doc strio
      ### $$$ info "strio: #{strio.string}".green      
    end
  end
end
