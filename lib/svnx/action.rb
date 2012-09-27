#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module SVNx
  # $$$ this cries for a little metaprogramming ... tomorrow

  class Action
    include Loggable, Comparable    
    
    attr_reader :type

    def initialize str
      @type = case str
              when 'added', 'A', :added
                :added
              when 'deleted', 'D', :deleted
                :deleted
              when 'modified', 'M', :modified
                :modified
              when 'unversioned', '?', :unversioned
                :unversioned
              end
    end

    def added?
      @type == :added
    end

    def deleted?
      @type == :deleted
    end
    
    def modified?
      @type == :modified
    end
    
    def unversioned?
      @type == :unversioned
    end

    def <=> other
      @type.to_s <=> other.type.to_s
    end
  end
end
