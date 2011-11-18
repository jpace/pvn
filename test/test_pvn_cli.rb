require File.join(File.dirname(__FILE__), "test_helper.rb")
require 'pvn/cli'

class TestPVNCli < Test::Unit::TestCase
  def setup
    PVN::CLI.execute(@stdout_io = StringIO.new, Array.new)
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  def test_print_default_output
    # assert_match(/To update this executable/, @stdout)
  end
  
  def xxx_test_help
    io = StringIO.new
    PVN::CLI.execute(io, %w{ --help })
    io.rewind
    io = io.read
    # assert_match(/To update this executable/, io)
  end
end
