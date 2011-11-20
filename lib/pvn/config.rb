#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'singleton'

module PVN
  class Configuration
    include Singleton

    def initialize
      puts "initializing"
      @values = Hash.new { |h, k| h[k] = Array.new }
    end

    def config &blk
      blk.call self
    end

    def self.config &blk
      self.instance.config(&blk)
    end

    def read
      require '/home/jpace/.pvn'
    end

    def value name, field
      @values[name][field]
    end

    def method_missing meth, *args, &blk
      eqre = Regexp.new('^(\w+)=')
      puts "method missing: #{meth}"
      if md = eqre.match(meth.to_s)
        name = md[1]
        @values[@current] << [ name, args ]
        puts "@values: #{@values}"
      else
        @current = meth
        yield self
        @current = nil
      end
    end
  end
end


if __FILE__ == $0
  cfg = PVN::Configuration.instance
  cfg.read
end
