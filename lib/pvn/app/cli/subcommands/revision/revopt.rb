#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'synoption/option'

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
      super :revision, '-r', REVISION_DESCRIPTION, revargs
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
  end
end
