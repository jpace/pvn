require File.dirname(__FILE__) + '/../test_helper.rb'

require 'rubygems'
require 'riel'
require 'pvn/commands/log'
require 'commands/command_test'

RIEL::Log.level = Log::DEBUG
RIEL::Log.set_widths(-12, 4, -35)

module PVN
  class TestLogEntry < CommandTest
    include Loggable

    def test_log_line_regexp
      logoutput = read_testfile 'svnlog.r450.r470.txt'

      logoutput.each_with_index do |line, lidx|
        ln = line.chomp
        if PVN::Log::TextOutputReader::LOG_SEPARATOR_RE.match(ln)
          if lidx + 1 < logoutput.length
            logline = logoutput[lidx + 1]
            md = PVN::Log::TextOutputReader::LOG_RE.match(logline)
            assert_not_nil md, logline
          end
        end
      end
    end

    def assert_entries_match expected, entry
      info "expected: #{expected}".green

      expected.each do |field, expval|
        info "field: #{field}; expval: #{expval}"
        actval = entry.send field
        info "actval: #{actval}"

        assert_equal expval, actval, "field: #{field} in #{entry.inspect}"
      end
    end

    def test_create_from_terse_text
      logoutput = read_testfile 'svnlog.r450.r470.txt'
      # info "logoutput: #{logoutput}"

      entry_idx = 0

      entries = Hash.new
      entries[0] = { 
        :revision => '457', 
        :user     => 'hielke.hoeve@gmail.com',
        :date     => '2010-10-15',
        :time     => '03:14:28',
        :tz       => '-0400',
        :dtg      => 'Fri, 15 Oct 2010',
        :nlines   => '1',
        :files    => nil,
        :comment  => [
                      'merged /branches/issue-67 r456 into trunk.' 
                     ]
      }

      entries[2] = { 
        :revision => '459',
        :user     => 'roche.jul',
        :date     => '2010-10-17',
        :time     => '15:57:05',
        :tz       => '-0400',
        :dtg      => 'Sun, 17 Oct 2010',
        :nlines   => '9',
        :files    => nil,
        :comment  => [
                      'Wiquery 1.1 & 1.1 examples',
                      '',
                      '-> add the following maven repository:',
                      '',
                      '                <repository> ',
                      '                        <id>maven.atlassian.com</id> ',
                      '                        <name>maven.atlassian.com</name> ',
                      '                        <url>https://maven.atlassian.com/3rdparty</url> ',
                      '                </repository> ',
                     ]
      }

      entries[10] = { 
        :revision => '470',
        :user     => 'roche.jul',
        :date     => '2010-11-04',
        :time     => '18:53:03',
        :tz       => '-0400',
        :dtg      => 'Thu, 04 Nov 2010',
        :nlines   => '4',
        :files    => nil,
        :comment  => [
                      'Wiquery 1.1 && WiQuery 1.0.3',
                      '',
                      '-> fix issue 94',
                      '-> little change for the ComponentTester: compliance with JDK 1.5',
                     ]
      }

      entries = Array.new
      
      lidx = 0
      while creation = PVN::Log::Entry.create_from_text(logoutput, lidx)
        entry = creation[0]
        info "entry: #{entry.inspect}"
        lidx = creation[1]
        info "lidx: #{lidx}"

        expected = entries[entry_idx]
        if expected
          assert_entries_match expected, entry
        end

        entries << entry

        entry_idx += 1
      end

      assert_equal 11, entries.length
    end
  end
end
