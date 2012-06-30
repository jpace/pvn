#!/usr/bin/ruby -w
# -*- ruby -*-

require 'svnx/log/tc'
require 'svnx/log/command'

module PVN
  class Environment
    TEST_DIR = '/Programs/wiquery/trunk'
  end
end

$orig_location = Pathname.new(__FILE__).expand_path

module PVN
  class ResourceFile < File
    include Loggable

    def initialize args
      info "args: #{args}".on_green

      dir = PVN::Environment::TEST_DIR

      loc = $orig_location
      6.times { loc = loc.parent }
      resdir = loc + 'test/resources'
      fname   = resdir + (dir.sub(%r{^/}, '').gsub('/', '_') + '__' + args.join('_'))
      info "fname: #{fname}".cyan

      super fname
    end
  end
  
  class CommandLine
    def command_to_resource_file
    end

    def execute
      rf = ResourceFile.new @args
      @output = rf.readlines
    end
  end
end

module SVNx
  module Log
    class CommandTestCase < SVNx::Log::TestCase
      include Loggable

      def setup
        @cache_dir = PVN::Environment.instance.cache_dir
        info "@cache_dir: #{@cache_dir}"
        remove_cache_dir
        
        super

        @origdir = Dir.pwd
        Dir.chdir '/Programs/wiquery/trunk'
      end

      def teardown
        remove_cache_dir        
        super
      end

      def assert_log_entries cmd
        info "cmd: #{cmd}"
        doc = REXML::Document.new cmd.output.join ''

        elements = doc.elements
        assert_equal 1, elements.size

        logelmt = elements[1]

        assert_equal 'log', logelmt.name
        
        logentryelmts = logelmt.elements

        assert_equal 163, logentryelmts.size

        expdata = Hash.new
        expdata[:author] = 'jpace'
        expdata[:date] = '2011-12-05T12:41:52.385786Z'
        expdata[:msg] = 'Testing.'

        assert_log_entry logentryelmts[1], expdata

        expdata = Hash.new
        expdata[:author] = 'hielke.hoeve@gmail.com'
        expdata[:date] = '2011-09-28T14:32:43.601185Z'
        expdata[:msg] = 'rework of the js/css/string tokens for post rendering.'
        assert_log_entry logentryelmts[17], expdata
      end

      def test_xml_output
        cmd = LogCommand.new :use_cache => false
        assert_log_entries cmd
      end

      def test_cache_not_created
        assert_cache_dir_exists false
        cmd = LogCommand.new :use_cache => false
        assert_cache_dir_exists false
      end        

      def test_cache_created
        assert_cache_dir_exists false
        cmd = LogCommand.new :use_cache => true
        
        # todo: fix this to mock creating the cache directory
        # assert_cache_dir_exists true
      end
    end
  end
end
