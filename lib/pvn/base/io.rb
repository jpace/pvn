#!/usr/bin/ruby -w
# -*- ruby -*-

module PVN
  class IO < ::IO
    
    def self.numlines io
      io.readlines.size
    end
  end
end
