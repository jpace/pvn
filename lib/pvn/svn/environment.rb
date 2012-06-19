#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'singleton'

module PVN
  class Environment
    include Singleton

    DEFAULT_CACHE_DIR = '/tmp/pvn_testing_cache_dir'

    attr_accessor :cache_dir
    
    def initialize
      super

      @cache_dir = DEFAULT_CACHE_DIR
    end
  end
end

