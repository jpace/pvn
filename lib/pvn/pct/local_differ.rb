#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/pct/differ'
require 'svnx/exec'

module PVN::Pct
  class LocalDiffer < Differ
    def get_diff_counts path, options
      elmt = PVN::IO::Element.new :local => path
      modified = elmt.find_modified_files

      # total = PVN::DiffCount.new

      modified = modified.sort_by { |n| n.path }

      diff_counts = Array.new

      modified.each do |entry|
        info "entry.path: #{entry.path}"
        lines = SVNx::Exec.new.cat entry.path, nil, false
        svn_count = lines.size
        local_count = Pathname.new(entry.path).readlines.size
        
        dc = PVN::DiffCount.new svn_count, local_count, entry.path
        diff_counts << dc
      end

      diff_counts
    end
  end
end
