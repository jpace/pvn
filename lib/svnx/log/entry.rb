#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/entry'

module SVNx; module Log; end; end

module SVNx::Log
  class Entry < SVNx::Entry

    attr_reader :revision, :author, :date, :paths, :msg

    def set_from_element elmt
      set_attr_var elmt, 'revision'

      %w{ author date msg }.each do |field|
        set_elmt_var elmt, field
      end
      
      @paths = Array.new

      elmt.elements.each('paths/path') do |pe|
        kind = get_attribute pe, 'kind'
        action = get_attribute pe, 'action'
        name = pe.text

        @paths << LogEntryPath.new(:kind => kind, :action => action, :name => name)
      end
    end

    def message
      @msg
    end

    def to_s
      [ @revision, @author, @date, @msg, @paths ].collect { |x| x.to_s }.join " "
    end
  end

  class LogEntryPath
    attr_reader :kind, :action, :name
    
    def initialize args = Hash.new
      @kind = args[:kind]
      @action = args[:action]
      @name = args[:name]
    end

    def to_s
      @name
    end
  end
end
