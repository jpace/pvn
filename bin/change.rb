#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

class LocalChange
  TODIR = '/Projects/pvn/pvntestbed.pending'
  RESDIR = 'test/resources'
end

class LocalChangeZero < LocalChange
  attr_reader :fromdir
  
  def initialize 
    @fromdir = 'change0'
    
    copyfiles = Array.new
    copyfiles << 'FirstFile.txt'
    copyfiles << 'src/ruby/dog.rb'
    copyfiles << 'src/java/Charlie.java'
    copyfiles << 'SeventhFile.txt'

    deletefiles = Array.new
    deletefiles << 'dirzero/SixthFile.txt'

    origdir = Dir.pwd
    Dir.chdir 'test/resources/' + fromdir

    copyfiles.each do |cpfile|
      copy_file cpfile
    end

    deletefiles.each do |delfile|
      delete_file delfile
    end

    Dir.chdir origdir
  end

  def copy_file fname
    puts "fname: #{fname}"
  end

  def delete_file fname
    puts "fname: #{fname}"
  end
end

LocalChangeZero.new
