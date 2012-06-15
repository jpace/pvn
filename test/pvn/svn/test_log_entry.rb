#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/log/entry'
# require 'pvn/svn/log/xmllog'
require 'rexml/document'

Log.level = Log::DEBUG
Log.set_widths(-12, 4, -35)

module PVN
  module SVN
    class TestLogEntry < PVN::TestCase
      include Loggable

      TEST_LINES = Array.new
      TEST_LINES << '<?xml version="1.0"?>'
      TEST_LINES << '<log>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1949">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-28T08:33:35.737406Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-jquery-ui/.settings/org.eclipse.wst.common.project.facet.core.xml</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-core/pom.xml</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-core/.settings/org.eclipse.wst.common.component</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-jquery-ui/pom.xml</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-core/.settings/org.eclipse.jdt.core.prefs</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-jquery-ui/.settings/org.eclipse.wst.common.component</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/pom.xml</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-jquery-ui/.settings/org.eclipse.jdt.core.prefs</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-jquery-ui/src/main/java/org/odlabs/wiquery/ui/autocomplete/AbstractAutocompleteComponent.java</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/droppable/DroppableAjaxBehaviorTestCase.java</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/branches/wiquery-6/wiquery-core/.settings/org.eclipse.wst.common.project.facet.core.xml</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>changes to begin wicket 6 development'
      TEST_LINES << '</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1948">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-28T08:24:15.320333Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="dir"'
      TEST_LINES << '   copyfrom-path="/trunk"'
      TEST_LINES << '   copyfrom-rev="1947"'
      TEST_LINES << '   action="A">/branches/wiquery-6</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>dev branch'
      TEST_LINES << '</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1947">'
      TEST_LINES << '<author>reiern70</author>'
      TEST_LINES << '<date>2011-11-14T12:24:45.757124Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>added a convenience method to set the range</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1946">'
      TEST_LINES << '<author>reiern70</author>'
      TEST_LINES << '<date>2011-11-14T12:11:07.945796Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/trunk/wiquery-jquery-ui/src/main/java/org/odlabs/wiquery/ui/slider/SliderRange.java</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>fixed javadoc</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1945">'
      TEST_LINES << '<author>reiern70</author>'
      TEST_LINES << '<date>2011-11-14T12:10:46.647098Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/trunk/wiquery-jquery-ui/src/main/java/org/odlabs/wiquery/ui/slider/Slider.java</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>added a convenience method to set the range</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1944">'
      TEST_LINES << '<author>reiern70</author>'
      TEST_LINES << '<date>2011-11-14T12:10:12.107142Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/trunk/wiquery-jquery-ui/src/main/java/org/odlabs/wiquery/ui/slider/AjaxSlider.java</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>returning default value: it was always returning 0</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1943">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:56:09.645565Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-tests.jar.sha1</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-tests.jar</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-tests.jar.md5</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1942">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:56:06.395675Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1941">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:56.179059Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-javadoc.jar.md5</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-javadoc.jar.sha1</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-javadoc.jar</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1940">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:53.087732Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1939">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:45.152232Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-test-sources.jar.sha1</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-test-sources.jar</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-test-sources.jar.md5</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1938">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:42.122879Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1937">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:29.424242Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-sources.jar.sha1</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-sources.jar</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/wiquery-jquery-ui-1.5-SNAPSHOT-sources.jar.md5</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1936">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:26.339380Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '<logentry'
      TEST_LINES << '   revision="1935">'
      TEST_LINES << '<author>hielke.hoeve@gmail.com</author>'
      TEST_LINES << '<date>2011-11-14T10:55:18.369868Z</date>'
      TEST_LINES << '<paths>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/maven-metadata.xml.sha1</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/maven-metadata.xml</path>'
      TEST_LINES << '<path'
      TEST_LINES << '   kind="file"'
      TEST_LINES << '   action="M">/repo/org/odlabs/wiquery/wiquery-jquery-ui/1.5-SNAPSHOT/maven-metadata.xml.md5</path>'
      TEST_LINES << '</paths>'
      TEST_LINES << '<msg>Upload by wagon-svn</msg>'
      TEST_LINES << '</logentry>'
      TEST_LINES << '</log>'

      def assert_log_re_match line, expdata
        md = Entry::LOG_SUMMARY_RE.match line

        assert_not_nil md
        (1 .. 7).each do |idx|
          assert_equals expdata[idx - 1], md[idx], "field: #{idx}"
        end

        md
      end

      def assert_xml_document_match line, expdata
        md = Entry::LOG_SUMMARY_RE.match line

        assert_not_nil md
        (1 .. 7).each do |idx|
          assert_equals expdata[idx - 1], md[idx], "field: #{idx}"
        end

        md
      end

      def assert_entry_equals entry, expdata
        assert_equals expdata[0], entry.revision
        assert_equals expdata[1], entry.author
        assert_equals expdata[2], entry.date
        assert_equals expdata[3], entry.message
        entry.paths.each_with_index do |path, idx|
          info path.inspect.yellow
          assert_equals expdata[4 + idx][:kind], path.kind
          assert_equals expdata[4 + idx][:action], path.action
          assert_equals expdata[4 + idx][:name], path.name
        end
      end

      def get_attribute xmlentry, attrname
        xmlentry.attributes[attrname]
      end

      def get_element_text xmlentry, elmtname
        xmlentry.elements[elmtname].text
      end
      
      def test_entry_from_xml
        expdata = '1947', 'reiern70', '2011-11-14T12:24:45.757124Z', 'added a convenience method to set the range'
        expdata << { :kind => 'file', :action => 'M', :name => '/trunk/wiquery-jquery-ui/src/test/java/org/odlabs/wiquery/ui/slider/SliderTestCase.java' }

        doc = REXML::Document.new TEST_LINES.join('')
        info "doc: #{doc}"

        entries = Array.new

        # log/logentry
        xmlentry = doc.elements[1].elements[3]
        info "xmlentry: #{xmlentry}".on_blue

        entry = Entry.create_from_xml_element xmlentry
        
        # md = assert_log_re_match TEST_LINES[1], expdata
        assert_entry_equals entry, expdata
      end
    end
  end
end
