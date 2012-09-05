#!/usr/bin/ruby -w
# -*- ruby -*-

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

class Resources
  include Singleton

  WIQ_TRUNK_STATUS = WiqTrSvnResource.new 'status'

  WIQ_LOG_L_15  = WiqSvnResource.new 'log', '-l', '15'
  WIQ_LOG       = WiqSvnResource.new 'log'  
  WIQ_LOG_R1    = WiqSvnResource.new 'log', '-r1'
  WIQ_LOG_R1748 = WiqSvnResource.new 'log', '-r1748'

  WIQTR_INFO_WIQUERY_CORE_POM_XML = WiqTrSvnResource.new 'info', 'wiquery-core/pom.xml'
  WIQTR_INFO_POM_XML_ORIG_JAVA    = WiqTrSvnResource.new 'info', 'pom.xml', 'Orig.java'

  WIQTR_LOG_L_15_V = WiqTrSvnResource.new 'log', '-l', '15', '-v'
  WIQTR_LOG_POM_XML = WiqTrSvnResource.new 'log', 'pom.xml'

  def generate
  end
end
