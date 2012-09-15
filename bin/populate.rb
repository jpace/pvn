#!/usr/bin/ruby -w
# -*- ruby -*-

require 'rubygems'
require 'riel'

Log.level = Log::DEBUG

class BinaryFile
  # binary files can contain other binaries
end


class TextFile
end

# for diff (diffj, xmldiff):
#    multiple revisions of those file types (.java, .xml)

# for pct, diff, etc.
#    locally changed files
#    revisions

# checkins of one file, multiple files

# add, change and delete in one checkin

class Change
  def initialize user, comment, files = Hash.new
    
  end
end


class Script
  def initialize 
    # Change.new('Taggart', 'Listen, dummy ...',
    #            :add => dir0/OldTest.0.java,
    #            )
    
    # Change.new('Mongo', 'Mongo like candy',
    #            :add => dir1/dira/IUtil.0.java,
    #            :mod => dir1/dira/StringExt.1.java,
    #            :del => dir0/OldTest.java,
    #            )
    
    # Change.new('Lyle', 'How about some more beans, Mr. Taggart?',
    #            :mod => dir1/dira/StringExt.2.java,
    #            )
    
    # Change.new('Jim', 'The big fella is taking a liking to you.',
    #            :del => dir1/dira/StringExt.2.java,
    #            )

    # tgz = BinaryFile.new(:outfile => dir1/dir2/TarBall.tar.gz,
    #                      :infiles => [ dir1/dir2/alpha.0.png, dir1/dir2/bravo.1.jpg ])

    # bf2 = BinaryFile.new(:outfile => dir0/BZipper.bz2, :infiles => [ tgz, dir1/dir2/StringExt.1.java ])

    # Change.new('Mongo', 'Added binaries', [ tgz, bf2 ])
  end
end

module SVN
  FROMREPO = '/Programs/Subversion/Repositories/pvntestbed.from'
  TOREPO = '/Programs/Subversion/Repositories/pvntestbed.to'
  CHECKOUT_DIR = '/Programs/pvn/pvntestbed.from'
  DUMPFILE = '/tmp/pvntestbed.dump'

  COMPRESSED_FILES = %w{ zip gzip tar tar.gz bz2 tar.bz2 jar }
  BINARY_FILES = %w{ jpg png pdf class }
  TEXT_FILES = %w{ rb rake java txt class pl pm xml html css gradle }

  module ClassMethods
  end

  def self.included base
    base.extend ClassMethods
  end
end

class SVN::Base
  include Loggable
  
  def run_command *cmd
    cmdstr = cmd.join(' ')
    info "cmdstr: #{cmdstr}".red
    # return if true

    IO.popen(cmd.join(' ')) do |io|
      puts io.readlines
    end
  end

  def remove dir
    pn = Pathname.new dir
    if pn.exist?
      dest = "/tmp/#{pn.basename}." + Time.new.to_i.to_s
      info "copying #{dir} to #{dest}"
      FileUtils.cp_r dir, dest

      info "removing #{pn}".red
      pn.rmtree if pn.exist?
    end
  end
end

module SVN
  class Repository < Base
    attr_reader :dir

    def initialize dir
      @dir = dir
    end

    def create
      remove dir
      
      run_command 'svnadmin', 'create', dir
      run_command 'chgrp', 'lusers', '-R', dir
    end

    def dump
      run_command 'svnadmin', 'dump', @dir, '>', DUMPFILE
    end

    def load
      run_command 'svnadmin', 'load', @dir, '<', DUMPFILE
    end

    def checkout
      remove CHECKOUT_DIR

      run_command 'svn', 'co', 'file://' + @dir, CHECKOUT_DIR
    end
  end
end


class SvnRepoCreator
  
end

module SVN
  class Populator < Base

    # text files are by different versions:
    # Foo.0.add.java == add
    # Foo.1.mod.java == modify
    # Foo.2.mod.java == modify
    # Foo.3.del.java == delete

    # Foo.4.add.java == add (second time)
    # Foo.5.mod.java == modify
    # Foo.6.chg.java == change, but do not check in

    # path/to/something/Bar.txt

    # Name.0.add.zip = { Foo.0.add.java, Bar.1.mod.txt, Baz.0.png }:
    #   change to Foo.java, Bar.txt, Baz.png
    #   create zipfile
    #   add zipfile

    # Name.1.chg.zip = { Foo.1.java, Bar.3.txt, Baz.1.png }:
    #   change to Foo.java, Bar.txt, Baz.png
    #   delete zipfile
    #   create zipfile
    #   modify zipfile

    USERS = [ 
             'Bart',
             'Jim', 
             'Taggart',
             'Hedley Lamarr', 
             'Lili Von Shtupp', 
             'Governor William J. Lepetomane',
             'Lyle',
             'Mongo',
             'Buddy Bizarre',
             'Miss Stein'
            ]

    DOMAIN = 'rockridge.com'

    def initialize 
      create_src_repo

      generate

      modify_dates

      create_dest_repo

      cleanup

      # svn co 'file://' + TOREPO /Programs/pvntestbed
    end

    def create_src_repo
      pn = Pathname.new TOREPO
      pn.rmtree if pn.exist?

      run_command 'svnadmin', 'create', FROMREPO
      run_command 'chgrp', 'lusers', '-R', FROMREPO
    end

    def generate
      # add subdirectories
      # add files

      dir = Pathname.new TMPDIR
      info "dir: #{dir}".cyan
      dir.rmtree if dir.exist?

      run_command 'svn', 'co', 'file://' + FROMREPO, TMPDIR
      Dir.chdir dir
      
      # ln -s deleted FileToDelete.txt
    end

    def modify_dates
      # modify dates in DUMPFILE
      # start with 2011-12-10, increment randomly, not going past present date
    end

    def create_dest_repo
      run_command 'svnadmin', 'dump', FROMREPO, '>', DUMPFILE
      run_command 'svnadmin', 'create', TOREPO
      run_command 'svnadmin', 'load', TOREPO, '<', DUMPFILE
    end

    def cleanup
      pn = Pathname.new FROMREPO
      info "pn: #{pn}".yellow
      pn.rmtree
    end

    def add_file dir, fname, username, password = nil # password evidently not used.
    end

    def delete_file dir, fname, username
    end

    def change_file dir, fname, username
    end
  end
end

repo = nil

ARGV.each do |arg|
  case arg
  when "from"
    repo = SVN::Repository.new SVN::FROMREPO
  when "to"
    repo = SVN::Repository.new SVN::TOREPO
  when "create"
    repo.create
  when "dump"
    repo.dump
  when "checkout"
    repo.checkout
  when "load"
    repo.load
  else
    raise "invalid argument: #{arg}"
  end
end

# SVN::Populator.new
