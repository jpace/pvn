#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module SVN
  # Info has the results of "svn info <file>", where the values returned are
  # keys and values in a Hash.
  class Info < Hash
    include Loggable
    
    def initialize args
      RIEL::Log.info "args: #{args}".green
      @name = args[:name]
      super()
       
      execute
    end

    def execute
      cmd = "svn info #{@name}"
      output = %x{#{cmd}}

      kv_re = Regexp.new '^(.*?):\s*(.*)'
      
      info = Hash.new
      output.split("\n").each do |line|
        key, value = kv_re.match(line)[1, 2]
       
        # debug "key: #{key}"
        # debug "value: #{value}"

        keysym = key.downcase.gsub(' ', '_').to_sym
        # debug "keysym: #{keysym}"

        self[keysym] = value
      end
      info
    end
  end
end
