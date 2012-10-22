#!/usr/bin/ruby -w
# -*- ruby -*-

require 'pvn/revision/base_option'

module PVN
  class RevisionOption < BaseRevisionOption
    attr_accessor :fromdate
    attr_accessor :todate

    def initialize revargs = Hash.new
      @fromdate = nil
      @todate = nil
      super :revision, '-r', description, nil, revargs
    end

    def description
      REVISION_DESCRIPTION
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
  end
end
