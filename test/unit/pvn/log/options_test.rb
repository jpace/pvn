#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/log/options'
require 'resources'

module PVN; module App; module Log; end; end; end

module PVN::App::Log
  class OptionsTest < PVN::TestCase
    def assert_options exp, args
      options = PVN::Log::OptionSet.new 
      options.process args

      assert_equal exp[:limit], options.limit
      assert_equal exp[:revision], options.revision
      
      exppaths = exp[:path] ? [ exp[:path] ] : exp[:paths]
      assert_equal exppaths, options.paths
    end

    def run_revision_test arg, *rev
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = rev
      expdata[:path] = Resources::PT_PATH
      assert_options expdata, [ arg, Resources::PT_PATH ].flatten
    end

    def test_default
      expdata = Hash.new
      expdata[:limit] = 5
      expdata[:paths] = Array.new
      assert_options expdata, Array.new
    end

    def test_limit
      expdata = Hash.new
      expdata[:limit] = 15
      expdata[:paths] = Array.new
      assert_options expdata, %w{ --limit 15 }
    end

    def test_help
      expdata = Hash.new
      expdata[:limit] = 5
      expdata[:revision] = nil
      expdata[:paths] = Array.new
      expdata[:help] = true
      assert_options expdata, %w{ --help }
    end          

    def test_revision_single
      run_revision_test '-r500', '500' 
    end

    def test_revision_multi
      run_revision_test '-r500:600', '500:600'
    end

    def test_revisions_single
      run_revision_test %w{ -r1 -r3 }, '1', '3'
    end
  end
end
