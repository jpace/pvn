#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/subcommands/diff/options'
require 'tempfile'
require 'pvn/subcommands/diff/differ'

module PVN::Subcommands::Diff
  class LocalDiffer < Differ
    def initialize options
      super
      
      paths = options.paths
      paths = %w{ . } if paths.empty?

      info "paths: #{paths}".yellow

      allentries = Array.new

      # we sort only the sub-entries, so the order in which paths were specified is preserved

      @whitespace = options.whitespace

      paths.each do |path|
        info "path: #{path}".red
        elmt = PVN::IO::Element.new :local => path
        entries = elmt.find_files_by_status
        
        allentries.concat entries.sort_by { |n| n.path }
      end

      info "allentries: #{allentries}"

      allentries.each do |entry|
        info "entry: #{entry.inspect}".on_blue
        case entry.status
        when 'modified'
          show_as_modified entry
        when 'deleted'
          show_as_deleted entry
        when 'added'
          show_as_added entry
        end
      end
    end

    ### $$$ todo: integrate these, from old diff/diffcmd
    def use_cache?
      super && !against_head?
    end

    def against_head?
      @options.change.value.nil? && @options.revision.head?
    end

    def read_working_copy entry
      pn = Pathname.new entry.path
      pn.readlines
    end

    def show_as_added entry
      Tempfile.open('pvn') do |from|
        # from is an empty file
        from.close

        # I think this is always revision 0
        run_diff_command entry, 0, 0, from.path, entry.path
      end
    end

    def show_as_deleted entry
      elmt = PVN::IO::Element.new :local => entry.path

      svninfo = elmt.get_info
      lines = elmt.cat_remote

      Tempfile.open('pvn') do |from|
        from.puts lines
        from.close
        Tempfile.open('pvn') do |to|
          # to is an empty file
          to.close
          run_diff_command entry, svninfo.revision, nil, from.path, to.path
        end
      end
    end
    
    def show_as_modified entry
      # only doing working copy to remote now      
      elmt = PVN::IO::Element.new :local => entry.path

      svninfo = elmt.get_info
      remotelines = elmt.cat_remote

      fromrev = svninfo.revision
      torev = nil               # AKA working copy

      wclines = read_working_copy entry

      Tempfile.open('pvn') do |from|
        from.puts remotelines
        from.close
        Tempfile.open('pvn') do |to|
          to.puts wclines
          to.close
          run_diff_command entry, fromrev, torev, from.path, to.path
        end
      end
    end
  end
end
