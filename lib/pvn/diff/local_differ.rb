#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/diff/options'
require 'pvn/diff/differ'
require 'pvn/diff/local_path'
# require 'pvn/diff/status_path'

module PVN::Diff
  class LocalDiffer < Differ
    def initialize options
      super
      
      paths = options.paths
      paths = %w{ . } if paths.empty?

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified
      # is preserved

      paths.each do |path|
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status
        allentries.concat entries.sort_by { |n| n.path }
      end

      allentries.each do |entry|
        next if entry.status == 'unversioned'
        path = LocalPath.new entry
        path.show_diff @whitespace
      end
    end

    ### $$$ todo: integrate these, from old diff/diffcmd
    def use_cache?
      super && !against_head?
    end
  end
end
