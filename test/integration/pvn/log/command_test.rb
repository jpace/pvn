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

    def assert_command_output expected, args = Array.new
      super PVN::Log::Command, expected, args
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
      
      assert_command_output expected, %w{ -h }
    end

    def test_command_default
      expected = Array.new
      expected << "\e[1m22\e[0m        \e[1m-1\e[0m        \e[1m\e[36mLyle\e[0m                     \e[1m\e[35m12-09-18 11:32:19\e[0m"
      expected << ""
      expected << "\e[37mDon't pay no attention to that alky. He can't hold a gun, much less shoot it.\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"
      expected << "\e[1m21\e[0m        \e[1m-2\e[0m        \e[1m\e[36mGovernor William J. Le Petomane\e[0m \e[1m\e[35m12-09-18 11:30:10\e[0m"
      expected << ""
      expected << "\e[37mWe've gotta protect our phoney baloney jobs, gentlemen!\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"
      expected << "\e[1m20\e[0m        \e[1m-3\e[0m        \e[1m\e[36mHoward Johnson\e[0m           \e[1m\e[35m12-09-18 11:28:08\e[0m"
      expected << ""
      expected << "\e[37mY'know, Nietzsche says: \"Out of chaos comes order.\"\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"
      expected << "\e[1m19\e[0m        \e[1m-4\e[0m        \e[1m\e[36mLili von Shtupp\e[0m          \e[1m\e[35m12-09-16 14:24:07\e[0m"
      expected << ""
      expected << "\e[37m\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"
      expected << "\e[1m18\e[0m        \e[1m-5\e[0m        \e[1m\e[36mLili von Shtupp\e[0m          \e[1m\e[35m12-09-16 14:09:45\e[0m"
      expected << ""
      expected << "\e[37mWillkommen, Bienvenue, Welcome, C'mon in.\e[0m"
      expected << ""
      expected << "-------------------------------------------------------"

      assert_command_output expected
    end

    def test_command_user
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

      assert_command_output expected, %w{ -u Jim  }
    end
  end
end
