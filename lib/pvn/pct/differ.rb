#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/util/diffcount'
require 'riel/log/loggable'

module PVN::Pct
  class Differ
    include RIEL::Loggable

    def initialize options
      show_diff_counts options
    end

    def show_diff_counts options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      total = PVN::DiffCount.new 0, 0, 'total'

      paths.each do |path|
        diff_counts = get_diff_counts path, options
        
        diff_counts.each do |dc|
          total << dc
          dc.print
        end
      end

      total.print
    end
  end
end
