#!/usr/bin/ruby -w
# -*- ruby -*-

require 'tc'
require 'pvn/subcommands/log/options'

module PVN; module App; module Log; end; end; end

module PVN::App::Log
  class OptionsTest < PVN::TestCase
    def assert_options exp, args
      options = PVN::Subcommands::Log::OptionSet.new 
      options.process args

      assert_equal exp[:limit], options.limit
      assert_equal exp[:revision], options.revision
      
      exppaths = exp[:path] ? [ exp[:path] ] : exp[:paths]
      assert_equal exppaths, options.paths
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
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = [ '500' ]
      expdata[:path] = '/Programs/wiquery/trunk'
      assert_options expdata, %w{ -r500 /Programs/wiquery/trunk }
    end

    def test_revision_multi
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = [ '500:600' ]
      expdata[:path] = '/Programs/wiquery/trunk'
      assert_options expdata, %w{ -r500:600 /Programs/wiquery/trunk }
    end

    def test_revision_relative
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = [ '1944' ]
      expdata[:path] = '/Programs/wiquery/trunk'
      assert_options expdata, %w{ -5 /Programs/wiquery/trunk }
    end

    def test_revisions_single
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = [ '1', '3' ]
      expdata[:path] = '/Programs/wiquery/trunk'
      assert_options expdata, %w{ -r1 -r3 /Programs/wiquery/trunk }
    end

    def test_revisions_relative
      expdata = Hash.new
      expdata[:limit] = nil
      expdata[:revision] = [ '1944', '1848' ]
      expdata[:path] = '/Programs/wiquery/trunk'
      assert_options expdata, %w{ -5 -10 /Programs/wiquery/trunk }
    end
  end
end
