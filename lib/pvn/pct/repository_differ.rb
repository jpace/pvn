#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'pvn/pct/differ'
require 'pvn/revision/range'
require 'rainbow'

module PVN::Pct
  class RepositoryDiffer < Differ
    # 
    def get_from_to_revisions rev
      fromrev = nil
      torev = nil
      
      if rev.size == 1
        if md = Regexp.new('(.+):(.+)').match(rev[0])
          return [ md[1], md[2] ]
        else
          return [ (rev[0].to_i - 1).to_s, rev[0] ]
        end
      else
        return [ rev[0], rev[1] ]
      end
    end
    
    def get_diff_counts path, options
      diff_counts = Array.new

      revision = options.revision

      # revision -r20 is like diff -c20:
      info "revision: #{revision}".bright.color(:yellow)
      fromrev, torev = get_from_to_revisions revision
      info "fromrev: #{fromrev}".color(:yellow)
      info "torev: #{torev}".color(:yellow)
      
      elmt = PVN::IO::Element.new :local => path
      modified = elmt.find_modified_entries [ fromrev + ':' + torev ]

      modnames = modified.collect { |m| m.name }.sort.uniq

      reporoot = elmt.repo_root

      direlmt = PVN::IO::Element.new :local => '.'
      svninfo = direlmt.get_info

      filter = svninfo.url.dup
      filter.slice! svninfo.root
      info "filter: #{filter}"
      filterre = Regexp.new '^' + filter + '/'
      
      modnames.each do |mod|
        fullpath = reporoot + mod
        elmt = PVN::IO::Element.new :path => fullpath

        next unless elmt.has_revision? fromrev
        next unless elmt.has_revision? torev
        next if elmt.get_info.kind == 'dir'

        from_count = elmt.cat(fromrev).size
        to_count = elmt.cat(torev).size

        name = mod.dup
        name.slice! filterre

        dc = PVN::DiffCount.new from_count, to_count, name
        diff_counts << dc
      end

      diff_counts
    end
  end
end
