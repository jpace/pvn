#!/usr/bin/ruby -w
# -*- ruby -*-

require 'singleton'

class SvnResource
  include Loggable
  
  RES_DIR = '/proj/org/incava/pvn/test/resources/'
  
  def initialize dir, *cmd
    @dir = dir
    @cmd = cmd
    info "@cmd: #{@cmd}"
  end

  def to_path
    RES_DIR + @dir.sub(%r{^/}, '').gsub('/', '_') + '__' + @cmd.join('_').gsub('/', '__')
  end

  def readlines
    ::IO.readlines to_path
  end
end

class Resources
  include Singleton

  WIQ_TRUNK_STATUS = SvnResource.new '/Programs/wiquery/trunk', 'svn', 'status', '--xml'

  WIQ_LOG_L_15  = SvnResource.new '/Programs/wiquery', 'svn', 'log', '--xml', '-l', '15'
  WIQ_LOG       = SvnResource.new '/Programs/wiquery', 'svn', 'log', '--xml'  
  WIQ_LOG_R1    = SvnResource.new '/Programs/wiquery', 'svn', 'log', '--xml', '-r1'
  WIQ_LOG_R1748 = SvnResource.new '/Programs/wiquery', 'svn', 'log', '--xml', '-r1748'

  WIQTR_INFO_WIQUERY_CORE_POM_XML = SvnResource.new '/Programs/wiquery/trunk', 'svn', 'info', '--xml', 'wiquery-core/pom.xml'
  WIQTR_INFO_POM_XML_ORIG_JAVA = SvnResource.new '/Programs/wiquery/trunk', 'svn', 'info', '--xml', 'pom.xml', 'Orig.java'

  WIQTR_LOG_L_15_V = SvnResource.new '/Programs/wiquery/trunk', 'svn', 'log', '--xml', '-l', '15', '-v'
  WIQTR_LOG_POM_XML = SvnResource.new'/Programs/wiquery/trunk', 'svn', 'log', '--xml', 'pom.xml'

  def svn_wiq_trunk_status
    WIQ_TRUNK_STATUS.readlines
  end

  def generate
  end
end
