#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/info/tc'
require 'svnx/info/entry'

module SVNx::Info
  class EntryTestCase < SVNx::Info::TestCase
    include Loggable
    
    def test_entry_from_xml
      # svn info --xml ./wiquery-core/pom.xml
      xml = Array.new
      xml << '<?xml version="1.0"?>'
      xml << '<info>'
      xml << '<entry'
      xml << '   kind="file"'
      xml << '   path="wiquery-core/pom.xml"'
      xml << '   revision="1950">'
      xml << '<url>file:///home/jpace/Programs/Subversion/Repositories/wiquery/trunk/wiquery-core/pom.xml</url>'
      xml << '<repository>'
      xml << '<root>file:///home/jpace/Programs/Subversion/Repositories/wiquery</root>'
      xml << '<uuid>9d44104b-4b85-4781-9eca-83ed02b512a0</uuid>'
      xml << '</repository>'
      xml << '<wc-info>'
      xml << '<schedule>normal</schedule>'
      xml << '<depth>infinity</depth>'
      xml << '<text-updated>2011-11-28T11:26:07.772551Z</text-updated>'
      xml << '<checksum>3b2a51d21a9517a4d3dc5865c4b56db9</checksum>'
      xml << '</wc-info>'
      xml << '<commit'
      xml << '   revision="1907">'
      xml << '<author>hielke.hoeve@gmail.com</author>'
      xml << '<date>2011-11-14T10:50:38.389281Z</date>'
      xml << '</commit>'
      xml << '</entry>'
      xml << '</info>'

      xmllines = xml.collect { |line| line + "\n" }
      
      expdata = {
        :url => 'file:///home/jpace/Programs/Subversion/Repositories/wiquery/trunk/wiquery-core/pom.xml',
        :kind => 'file',
        :path => 'wiquery-core/pom.xml',
        :root => 'file:///home/jpace/Programs/Subversion/Repositories/wiquery'
      }

      entry = Entry.new :xmllines => xmllines.join('')
      assert_entry_equals entry, expdata
    end
  end
end
