#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'synoption/option'
require 'svnx/log/command'
require 'pvn/revision/entry'

module PVN
  class RevisionOption < Option
    attr_accessor :fromdate
    attr_accessor :todate

    REVISION_DESCRIPTION = [ "revision to apply.",
                             "ARG can be relative, of the form:",
                             "    +N : N revisions from the BASE",
                             "    -N : N revisions from the HEAD,",
                             "         when -1 is the previous revision" ,
                           ]
    
    def initialize revargs = Hash.new
      revargs[:setter] = :revision_from_args
      @fromdate = nil
      @todate = nil
      super :revision, '-r', REVISION_DESCRIPTION, nil, revargs
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end
    
    def value
      val = nil
      if @fromdate
        val = to_svn_revision_date @fromdate
      end

      if @todate
        val = val ? val + ':' : ''
        val += to_svn_revision_date @todate
      end

      if val
        val
      else
        super
      end
    end

    def head?
      value.nil? || value == 'HEAD'
    end

    def post_process optset, unprocessed
      val = value
      @value = relative_to_absolute val, unprocessed[0]
    end

    def relative_to_absolute rel, path
      logforrev = SVNx::LogCommandLine.new path
      logforrev.execute
      xmllines = logforrev.output

      reventry = PVN::Revisionxxx::Entry.new :value => rel, :xmllines => xmllines
      revval   = reventry.value.to_s
      revval
    end
  end
end
