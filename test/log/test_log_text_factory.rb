require 'test_helper'
require 'pvn/log/logfactory'

RIEL::Log.level = Log::DEBUG
RIEL::Log.set_widths(-12, 4, -35)

module PVN
  module Log
    class TestTextFactory < PVN::TestCase
      include Loggable

      def test_log_line_regexp
        logoutput = read_testfile 'svnlog.r450.r470.txt'

        logoutput.each_with_index do |line, lidx|
          ln = line.chomp
          if PVN::Log::SVN_LOG_SEPARATOR_LINE_RE.match(ln)
            if lidx + 1 < logoutput.length
              logline = logoutput[lidx + 1]
              md = PVN::Log::SVN_LOG_SUMMARY_LINE_RE.match(logline)
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

        exp_entries = Hash.new
        exp_entries[0] = { 
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

        exp_entries[2] = { 
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

        exp_entries[10] = { 
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

        tf = PVN::Log::TextFactory.new logoutput
        entries = tf.entries
        assert_equal 11, entries.length

        entries.each_with_index do |entry, idx|
          expected = exp_entries[idx]
          if expected
            assert_entries_match expected, entry
          end
        end
      end
    end
  end
end
