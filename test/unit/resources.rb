#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'singleton'

class SvnResource
  include Loggable
  
  RES_DIR = '/proj/org/incava/pvn/test/resources/'
  
  def initialize dir, cmd, args = Array.new
    @dir = dir
    @cmd = [ 'svn', cmd, '--xml' ] + args
  end

  def to_path
    RES_DIR + @dir.sub(%r{^/}, '').gsub('/', '_') + '__' + @cmd.join('_').gsub('/', '__')
  end

  def readlines
    ::IO.readlines to_path
  end

  def generate
    origdir  = Pathname.new(Dir.pwd).expand_path
    tgtdir   = RES_DIR
    svncmd   = @cmd.join(' ')
    outfname = @dir.sub(%r{^/}, '').gsub('/', '_') + '__' + @cmd.join('_').gsub(' ', '_').gsub('/', '__')
    outfile  = tgtdir + outfname

    Dir.chdir @dir
    
    IO.popen(svncmd) do |io|
      lines = io.readlines
      File.open(outfile, "w") do |io|
        io.puts lines
      end
    end
    Dir.chdir origdir.to_s
  end
end

class WiqSvnResource < SvnResource
  def initialize cmd, *args
    super '/Programs/wiquery', cmd, args
  end
end

class WiqTrSvnResource < SvnResource
  def initialize cmd, *args
    super '/Programs/wiquery/trunk', cmd, args
  end
end

class PtSvnResource < SvnResource
  def initialize cmd, *args
    super '/Programs/pvn/pvntestbed.from', cmd, args
  end
end

class Resources
  include Singleton

  WIQTR_PATH = '/Programs/wiquery/trunk'
  
  WIQ_TRUNK_STATUS = WiqTrSvnResource.new 'status'

  # WIQ_LOG_L_15  = WiqSvnResource.new 'log', '-l', '15'
  # WIQ_LOG       = WiqSvnResource.new 'log'  
  WIQ_LOG_R1    = WiqSvnResource.new 'log', '-r1'
  # WIQ_LOG_R1748 = WiqSvnResource.new 'log', '-r1748'

  WIQTR_INFO_WIQUERY_CORE_POM_XML = WiqTrSvnResource.new 'info', 'wiquery-core/pom.xml'
  WIQTR_INFO_POM_XML_ADDED_FILE_TXT = WiqTrSvnResource.new 'info', 'pom.xml', 'AddedFile.txt'

  WIQTR_LOG_L_15_V = WiqTrSvnResource.new 'log', '-l', '15', '-v'
  WIQTR_LOG_POM_XML = WiqTrSvnResource.new 'log', 'pom.xml'

  WIQTR_LOG_LIMIT_1 = WiqTrSvnResource.new 'log', '--limit', '1'
  WIQTR_LOG_LIMIT_5 = WiqTrSvnResource.new 'log', '--limit', '5'
  WIQTR_LOG_LIMIT_7 = WiqTrSvnResource.new 'log', '--limit', '7'
  WIQTR_LOG_LIMIT_163 = WiqTrSvnResource.new 'log', '--limit', '163'
  WIQTR_LOG_LIMIT_164 = WiqTrSvnResource.new 'log', '--limit', '164'

  PT_PATH = '/Programs/pvn/pvntestbed'
  
  # PT_STATUS   = PtSvnResource.new 'status'
  # PT_LOG_L_15 = PtSvnResource.new 'log', '-l', '15'
  # PT_LOG      = PtSvnResource.new 'log'  
  # PT_LOG_R1   = PtSvnResource.new 'log', '-r1'
  PT_LOG_R19  = PtSvnResource.new 'log', '-r19' # empty message

  # PT_LOG_SECONDFILE_TXT = PtSvnResource.new 'log', 'SecondFile.txt'
  PT_LOG_R22_13_SECONDFILE_TXT = PtSvnResource.new 'log', '-r22:13', 'SecondFile.txt'

  PT_LOG_R19_5 = PtSvnResource.new 'log', '-r19:5'

  # these are the equivalent of limits of 1, 5, 7, and 19, starting at revision 19

  # PT_LOG_R19_19 == PT_LOG_R19

  PT_LOG_R19_15 = PtSvnResource.new 'log', '-r19:15'
  PT_LOG_R19_13 = PtSvnResource.new 'log', '-r19:13'
  PT_LOG_R19_1  = PtSvnResource.new 'log', '-r19:1'

  def generate
    puts "this: #{self.class.constants}"
    self.class.constants.each do |con|
      puts "con: #{con}"
      res = self.class.const_get con
      puts "res: #{res}"
      next unless res.respond_to? :generate
      res.generate
    end
  end
end

if __FILE__ == $0
  if ARGV[0] == 'generate'
    Resources.instance.generate
  end
end
