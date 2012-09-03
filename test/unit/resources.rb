#!/usr/bin/ruby -w
# -*- ruby -*-

require 'singleton'

class Resources
  include Singleton

  def test_lines dir, *cmd
    respath = "/proj/org/incava/pvn/test/resources/" + dir.sub(%r{^/}, '').gsub('/', '_') + '__' + cmd.join('_').gsub('/', '__')
    lines = ::IO.readlines respath
  end
end
