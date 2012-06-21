#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'
require 'pvn_test'
require 'pvn/svn/revision/revision'

module PVN
  module SVN
    class TestRevision < PVN::TestCase
      include Loggable

      def assert_revision_equals expdata, revdata
        rev = Revision.new revdata
        
        assert_equal expdata[:from_revision], rev.from_revision
        assert_equal expdata[:to_revision],   rev.to_revision

        assert_equal expdata[:from_date],     rev.from_date
        assert_equal expdata[:to_date],       rev.to_date
        assert_equal expdata[:arguments],     rev.arguments
      end

      def create_expdata args
      end
      
      def test_from_to_revision
        expdata = Hash.new
        expdata[:from_revision] = '439'
        expdata[:to_revision]   = '455'
        expdata[:arguments]     = [ '-r', '439:455' ]

        assert_revision_equals expdata, { :from_revision => '439', :to_revision => '455' }
      end

      def test_from_revision
        expdata = Hash.new
        expdata[:from_revision] = '439'
        expdata[:arguments]     = [ '-r', '439' ]

        assert_revision_equals expdata, { :from_revision => '439' }
      end

      def test_to_revision
        expdata = Hash.new
        expdata[:to_revision] = '439'
        expdata[:arguments]     = [ '-r', '439' ]

        assert_revision_equals expdata, { :to_revision => '439' }
      end

      def test_from_to_date
        expdata = Hash.new
        expdata[:from_date] = '2010-09-28'
        expdata[:to_date]   = '2010-10-04'
        expdata[:arguments] = [ '-r', '{2010-09-28}:{2010-10-04}' ]

        assert_revision_equals expdata, { :from_date => '2010-09-28', :to_date => '2010-10-04' }
      end

      def test_from_date
        expdata = Hash.new
        expdata[:from_date] = '2010-09-28'
        expdata[:arguments] = [ '-r', '{2010-09-28}' ]

        assert_revision_equals expdata, { :from_date => '2010-09-28' }
      end

      def test_to_date
        expdata = Hash.new
        expdata[:to_date] = '2010-09-28'
        expdata[:arguments] = [ '-r', '{2010-09-28}' ]

        assert_revision_equals expdata, { :to_date => '2010-09-28' }
      end

      def test_from_revision_to_date
        expdata = Hash.new
        expdata[:from_revision] = '439'
        expdata[:to_date]       = '2010-10-04'
        expdata[:arguments]     = [ '-r', '439:{2010-10-04}' ]

        assert_revision_equals expdata, { :from_revision => '439', :to_date => '2010-10-04' }
      end

      def test_to_revision_from_date
        expdata = Hash.new
        expdata[:to_revision] = '439'
        expdata[:from_date]   = '2010-10-04'
        expdata[:arguments]   = [ '-r', '{2010-10-04}:439' ]

        assert_revision_equals expdata, { :to_revision => '439', :from_date => '2010-10-04' }
      end

      def test_head_nil
        rev = Revision.new Hash.new
        assert rev.head?
      end

      def test_head_to_revision
        rev = Revision.new({ :to_revision => 'HEAD' })
        assert rev.head?
      end
    end
  end
end
