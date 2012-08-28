#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'

module SVNx; module Log; end; end

module SVNx::Log
  class Entry < SVNx::Entry

    attr_reader :revision, :author, :date, :paths, :msg
    
    def initialize args = Hash.new
      # this is log/logentry from "svn log --xml"
      if xmlelement = args[:xmlelement]
        # info "xmlelement: #{xmlelement}".yellow
        set_attr_var xmlelement, 'revision'

        %w{ author date msg }.each do |field|
          set_elmt_var xmlelement, field
        end
        
        @paths = Array.new

        xmlelement.elements.each('paths/path') do |pe|
          kind = get_attribute pe, 'kind'
          action = get_attribute pe, 'action'
          name = pe.text

          @paths << LogEntryPath.new(:kind => kind, :action => action, :name => name)
        end
      else
        @revision = args[:revision]
        @author = args[:author]
        @date = args[:date]
        @paths = args[:paths]
        @message = args[:message]
      end
    end

    def message
      @msg
    end
  end

  class LogEntryPath
    attr_reader :kind, :action, :name
    
    def initialize args = Hash.new
      @kind = args[:kind]
      @action = args[:action]
      @name = args[:name]
    end
  end
end
