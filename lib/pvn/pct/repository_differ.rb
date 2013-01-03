#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/pct/differ'
require 'pvn/revision/range'
require 'rainbow'

module PVN::Pct
  class RepositoryDiffer < Differ
    def get_from_to_revisions rev
      fromrev = nil
      torev = nil
      
      if rev.size == 1
        if md = Regexp.new('(.+):(.+)').match(rev[0])
          [ md[1], md[2] ]
        else
          [ (rev[0].to_i - 1).to_s, rev[0] ]
        end
      else
        [ rev[0], rev[1] ]
      end
    end

    def get_modified elmt, fromrev, torev
      modified = elmt.find_modified_entries [ fromrev + ':' + torev ]
      modified.collect { |m| m.name }.sort.uniq
    end

    def has_revisions? elmt, fromrev, torev
      elmt.has_revision?(fromrev) && elmt.has_revision?(torev)
    end

    def directory? elmt
      elmtinfo = elmt.get_info
      elmtinfo.kind == 'dir'
    end

    def get_local_info
      direlmt = PVN::IO::Element.new :local => '.'
      direlmt.get_info
    end

    def get_line_count elmt, rev
      elmt.cat(rev).size
    end
    
    def get_diff_counts path, options
      revision = options.revision

      # revision -r20 is like diff -c20:
      fromrev, torev = get_from_to_revisions revision
      
      elmt = PVN::IO::Element.new :local => path
      modnames = get_modified elmt, fromrev, torev

      reporoot = elmt.repo_root

      svninfo = get_local_info

      filter = svninfo.url.dup
      filter.slice! svninfo.root
      filterre = Regexp.new '^' + filter + '/'
      
      diff_counts = Array.new
      modnames.each do |mod|
        fullpath = reporoot + mod
        elmt = PVN::IO::Element.new :path => fullpath

        next unless has_revisions? elmt, fromrev, torev
        next if directory? elmt

        from_count = get_line_count elmt, fromrev
        to_count = get_line_count elmt, torev

        name = mod.dup
        name.slice! filterre

        dc = PVN::DiffCount.new from_count, to_count, name
        diff_counts << dc
      end

      diff_counts
    end
  end
end
