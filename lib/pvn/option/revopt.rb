#!/usr/bin/ruby -w
# -*- ruby -*-

require 'riel'
require 'rubygems'
require 'pvn/util'
# require 'pvn/revision'

module PVN
  class RevisionOption < Option
    attr_accessor :fromdate
    attr_accessor :todate
    
    def initialize revargs = Hash.new
      revargs[:setter] = :revision_from_args
      revargs[:regexp] = PVN::Util::POS_NEG_NUMERIC_RE
      @fromdate = nil
      @todate = nil
      super :revision, '-r', "revision", revargs
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

    def xxxset
      # @todo
      require @@orig_file_loc.dirname.parent + 'revision.rb'
      Revision.revision_from_args optset, cmdargs
    end

    def head?
      value.nil? || value == 'HEAD'
    end
  end
end
