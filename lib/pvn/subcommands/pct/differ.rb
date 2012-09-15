#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/subcommands/pct/diffcount'

module PVN::Subcommands::Pct
  class Differ
    include Loggable

    def initialize options
      show_diff_counts options
    end

    def show_diff_counts options
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}"

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
