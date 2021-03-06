#!/usr/bin/ruby -w
# -*- ruby -*-

require 'logue/loggable'
require 'set'

module PVN::Diff
  # represents the paths from one revision through another.
  class Paths
    include Logue::Loggable, Enumerable

    # takes paths of the form ".", "foo.rb", etc.
    def initialize revision, paths
      @revision = revision
      @elements = SortedSet.new
      
      paths.each do |path|
        add_for_path path
      end
    end

    def add_for_path path
      raise "implement this"
    end

    def [] idx
      @elements.to_a[idx]
    end

    def size
      @elements.size
    end

    # returns a map from names to logpaths
    def to_map
      names_to_paths = Hash.new
      @elements.each { |path| names_to_paths[path.name] = path }
      names_to_paths
    end

    def each(&blk)
      @elements.each(&blk)
    end
  end
end
