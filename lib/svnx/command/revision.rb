#!/usr/bin/ruby -w
# -*- ruby -*-

module SVNx
  class Revision
    attr_reader :from_revision
    attr_reader :to_revision

    attr_reader :from_date
    attr_reader :to_date

    def initialize args
      @from_revision = args[:from_revision]
      @to_revision   = args[:to_revision]

      @from_date     = args[:from_date]
      @to_date       = args[:to_date]
    end

    def to_svn_revision_date date
      '{' + date.to_s + '}'
    end

    def head?
      @to_revision.nil? || @to_revision == 'HEAD'
    end

    def arguments
      args = Array.new
      rev = nil
      if @from_revision
        rev = @from_revision.to_s
      elsif @from_date
        rev = to_svn_revision_date(@from_date)
      end

      if @to_revision || @to_date
        if rev
          rev << ':'
        else
          rev = ''
        end

        if @to_revision
          rev << @to_revision.to_s
        else
          rev << to_svn_revision_date(@to_date)
        end
      end
      
      if rev
        args << '-r' << rev
      end
      
      args
    end
  end    
end
