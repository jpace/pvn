#!/usr/bin/ruby -w
# -*- ruby -*-

require 'integration/tc'
require 'pvn/log/command'
require 'stringio'

module PVN::Log
  class CommandTest < PVN::IntegrationTestCase
    
    def test_path
      Command.new [ PT_DIRNAME ]
    end
    
    def test_invalid_path
      assert_raises(RuntimeError) do
        Command.new %w{ /this/doesnt/exist }
      end
    end

    def test_doc
      strio = StringIO.new
      $io = strio

      expected = [
                  "log: Print log messages for the given files.",
                  "usage: log [OPTIONS] FILE...",
                  "",
                  "  Prints the log entries for the given files, with colorized output. Unlike 'svn",
                  "  log', which prints all log entries, 'pvn log' prints 15 entries by default. As",
                  "  with other pvn subcommands, 'pvn log' accepts relative revisions.",
                  "",
                  "Options:",
                  "",
                  "  -r [--revision] ARG      : revision to apply.",
                  "                             ARG can be relative, of the form:",
                  "                                 +N : N revisions from the BASE",
                  "                                 -N : N revisions from the HEAD,",
                  "                                      when -1 is the previous revision",
                  "                             Multiple revisions can be specified.",
                  "  :[-+]N|-r.+              : same as above",
                  "   [--color]               : show colorized output",
                  "                               default: true",
                  "  -C [--no-color]            ",
                  "  -l [--limit] ARG         : the number of log entries",
                  "                               default: 5",
                  "  --no-limit                 ",
                  "  -u [--user] ARG          : show only changes for the given user",
                  "  -f [--files]             : list the files in the change",
                  "  -h [--help]              : display help",
                  "  -v [--verbose]           : display verbose output",
                  "",
                  "Examples:",
                  "",
                  "  % pvn log foo.rb",
                  "    Prints the latest 15 log entries for foo.rb.",
                  "",
                  "  % pvn log -l 25 foo.rb",
                  "    Prints 25 log entries for the file.",
                  "",
                  "  % pvn log -3 foo.rb",
                  "    Prints the log entry for revision (HEAD - 3).",
                  "",
                  "  % pvn log +3 foo.rb",
                  "    Prints the 3rd log entry.",
                  "",
                  "  % pvn log -l 10 --no-color",
                  "    Prints the latest 10 entries, uncolorized.",
                  "",
                  "  % pvn log -r 122 -f",
                  "    Prints log entry for revision 122, including the files in that change.",
                  "",
                  "  % pvn log -u barney",
                  "    Prints log entries only for user 'barney', with the default limit.",
                 ]
      
      assert_command_output Command, expected, %w{ -h }
    end

    def test_user
      expected = Array.new
      expected << "\e[1m13\e[0m                  \e[1m\e[36mJim\e[0m                      \e[1m\e[35m12-09-16 13:51:55\e[0m"
      expected << ""
      expected << "\e[37mWe're not sure. Are we...black?\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"
      expected << "\e[1m3\e[0m                   \e[1m\e[36mJim\e[0m                      \e[1m\e[35m12-09-15 17:29:15\e[0m"
      expected << ""
      expected << "\e[37mBoy, is he strict!\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"

      assert_command_output Command, expected, %w{ -u Jim  }
      # filter_for_user
      # fetch_log_in_pieces (-n LIMIT, LIMIT * 2, LIMIT * 4, LIMIT * 8 ... )
      # PVN::Log::Command.new [ PT_DIRNAME ]
    end
  end
end
