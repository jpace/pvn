require 'tc'
require 'pvn/diff/diffcmd'

module PVN
  class TestDiff < PVN::TestCase
    include Loggable

    WIQUERY_URL = "file:///home/jpace/Programs/Subversion/Repositories/wiquery/trunk"
    TMP_DIR = "/proj/tmp"       # SSD here; /tmp is HDD
    WIQUERY_DIRNAME = "/Programs/wiquery/trunk"

    def setup
      info "setting up".blue
      super
    end

    def teardown
      info "tearing down".yellow
    end

    def backup_svn_repo
    end

    def restore_svn_repo
    end

    def goto_test_trunk
      Dir.chdir WIQUERY_DIRNAME
    end

    def assert_diff_command exp, cmdargs = nil
      origargs = cmdargs && cmdargs.dup
      assert_equal exp, DiffCommand.new(:execute => false, :command_args => cmdargs).command, "arguments: " + origargs.to_s
    end

    def xtest_documentation
      doc = DiffCommand.to_doc
      # puts "doc: #{doc}".on_green
    end

    ### $$$ disabled:
    def xtest_with_diffcmd
      assert_diff_command 'svn diff --diff-cmd /proj/org/incava/pvn/bin/pvndiff', %w{ }
    end

    ### $$$ disabled:
    def xtest_no_diff_command
      assert_diff_command 'svn diff', %w{ --no-diffcmd }
      assert_diff_command 'svn diff', %w{ --no-diff-cmd }
    end

    def test_none
      # write ~/.pvn/config.rb and load it ...
      doc = DiffCommand.to_doc
      # puts "doc: #{doc}".on_green
    end

    def assert_no_output cmd
      assert_equal 0, cmd.output.length
    end

    def run_svn_update
      # puts "run_svn_update".on_red
    end

    def run_svn_checkout
      # puts "run_svn_checkout".on_red
    end

    def test_no_change
      return "not implemented"

      goto_test_trunk
      run_svn_checkout
      cmd = DiffCommand.new :execute => true, :command_args => []
      # @todo assert_no_output cmd
    end

    def xxx_test_change
      goto_test_trunk
      run_svn_update
      append_to_file "somefile.txt", "new line\n"

      cmd = DiffCommand.new :execute => true, :command_args => []
      assert_output cmd, "> new line\n"
    end

    def xxx_test_against_head
      goto_test_trunk_two       # not the primary testing directory
      run_svn_update
      remove_from_file "anotherfile.txt", "goner line\n"

      cmd = DiffCommand.new :execute => true, :command_args => []
      assert_no_output cmd

      goto_test_trunk
      run_svn_update
      cmd = DiffCommand.new :execute => true, :command_args => []
      assert_no_output cmd

      headcmd = DiffCommand.new :execute => true, :command_args => %w{ -r HEAD }
      assert_output headcmd, "< goner line\n"
    end

    def test_between_two_revisions
      # diff -r 132:412
    end

    def test_change
      # diff -c 317
    end

    def test_revision_against_head
      # diff -r 317 (same as -r 317:HEAD)
    end

    def test_filter_known_type_java
      # diff --diff-cmd diffj Foo.java
    end

    def test_filter_unknown_type
      # diff foo.yaml
    end
  end
end
