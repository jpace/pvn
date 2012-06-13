#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

module PVN
  class SVNRootElement < SVNElement
    include Loggable
    attr_reader :name

    # returns the topmost directory for the repo root of the given (defaulting
    # to current) directory
    def self.new dirname = '.'
      dir = Pathname.new(dirname).expand_path
      
      while dir.to_s != '/'
        elmt = SVNElement.new :name => dir
        elmtinfo = elmt.info
        return elmt if elmtinfo[:repository_root] == elmtinfo[:url]
        return elmt if !(dir.parent + '.svn').exist?
        return nil  if elmtinfo[:repository_root].nil?
        dir += '..'
      end

      nil
    end    
  end
end
cd ~lib


