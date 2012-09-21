#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'singleton'

module PVN
  class Configuration
    def initialize
      @@instance = self
      @values = Hash.new { |h, k| h[k] = Array.new }
    end

    def config &blk
      blk.call self
    end

    def self.config &blk
      @@instance.config(&blk)
    end

    def self.read
      @@instance ||= begin
        cfg = self.new
        pvndir = ENV['HOME'] + '/.pvn'
        cfgfile = pvndir + '/config'
        
        begin
          require cfgfile
        rescue LoadError => e
          # no configuration
        end
        cfg
      end
    end

    def value name, field
      @values[name][field]
    end

    def section name
      @values[name]
    end

    def method_missing meth, *args, &blk
      eqre = Regexp.new('^(\w+)=')
      # puts "method missing: #{meth}"
      if md = eqre.match(meth.to_s)
        name = md[1]
        @values[@current] << [ name.to_s, *args ]
        # puts "@values: #{@values}"
      else
        @current = meth.to_s
        yield self
        @current = nil
      end
    end
  end
end

if __FILE__ == $0
  cfg = PVN::Configuration.read
end

__END__
# this is an example:
PVN::Configuration.config do |config|
  config.diff do |diff|
    diff.java = '/home/jpace/Programs/diffj-1.2.1/bin/diffj --context -L "{0}" -L "{1}" "{2}" "{3}"'
    diff.xmlorig  = "xmldiff --someopt=true --from-file '{0}' --to-file '{1}'"
  end
  
  config.log do |log|
    log.limit = 25
    log.format = '#{revision.red}\t#{user.bold}\t#{time} #{date}\n#{list(comment, :green)}#{cr(files)}#{list(files, :bold, :cyan)}\n'
  end
end
