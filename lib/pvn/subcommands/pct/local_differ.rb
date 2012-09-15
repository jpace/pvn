#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/io/element'
require 'svnx/cat/command'
require 'pvn/subcommands/pct/diffcount'
require 'pvn/subcommands/pct/differ'

module PVN::Subcommands::Pct
  class LocalDiffer < Differ
    def get_diff_counts path, options
      elmt = PVN::IO::Element.new :local => path
      modified = elmt.find_modified_files

      total = PVN::DiffCount.new

      modified = modified.sort_by { |n| n.path }

      diff_counts = Array.new

      modified.each do |entry|
        info "entry.path: #{entry.path}"
        catcmd      = SVNx::CatCommand.new entry.path
        svn_count   = catcmd.execute.size
        local_count = Pathname.new(entry.path).readlines.size
        
        dc = PVN::DiffCount.new svn_count, local_count, entry.path
        diff_counts << dc
      end

      diff_counts
    end
  end

  class RepositoryDiffer < Differ
    ### $$$ this belongs in Revision
    def get_from_to_revisions rev
      if rev.kind_of? Array
        if rev.size == 1
          if md = Regexp.new('(.+):(.+)').match(rev[0])
            return [ md[1], md[2] ]
          else
            return [ (rev[0].to_i - 1).to_s, rev[0] ]
          end
        else
          return [ rev[0], rev[1] ]
        end
      else
        info "rev: #{rev}".bold.white.on_red
      end
    end

    def get_line_count path, revision
      info "path: #{path}".yellow
      cmdargs = SVNx::CatCommandArgs.new :path => path, :revision => revision
      catcmd = SVNx::CatCommand.new cmdargs
      catcmd.execute.size
    end
    
    def get_diff_counts path, options
      diff_counts = Array.new

      revision = options.revision
      
      elmt = PVN::IO::Element.new :local => path
      modified = elmt.find_modified_entries revision

      modnames = modified.collect { |m| m.name }.sort.uniq

      fromrev, torev = get_from_to_revisions revision

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

        from_count = get_line_count fullpath, fromrev
        to_count = get_line_count fullpath, torev

        name = mod.dup
        name.slice! filterre

        dc = PVN::DiffCount.new from_count, to_count, name
        diff_counts << dc
      end

      diff_counts
    end
  end
end
