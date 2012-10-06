#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module SVNx
  # $$$ this cries for a little metaprogramming ... tomorrow

  class Action
    include Loggable, Comparable
    
    attr_reader :type

    STATUS_TO_TYPE = Hash.new

    def self.add_type sym, str, char
      [ sym, str, char ].each do |key|
        STATUS_TO_TYPE[key] = sym
      end
    end

    add_type :added, 'added', 'A'
    add_type :deleted, 'deleted', 'D'
    add_type :modified, 'modified', 'M'
    add_type :unversioned, 'unversioned', '?'

    STATUS_TO_TYPE.values.uniq.each do |val|
      methname = val.to_s + '?'
      define_method methname do
        instance_eval do
          @type == STATUS_TO_TYPE[val]
        end
      end
    end
    
    def initialize str
      @type = STATUS_TO_TYPE[str]
    end

    def <=> other
      @type.to_s <=> other.type.to_s
    end

    def to_s
      @type.to_s
    end
  end
end
