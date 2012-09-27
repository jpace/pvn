require 'tc'
require 'pvn/app'
require 'stringio'

class TestPVNCli < PVN::TestCase
  def setup
    stdout_io = StringIO.new
    # PVN::App::Runner.new stdout_io, Array.new
    # stdout_io.rewind
    @stdout = stdout_io.string
  end
  
  def xxx_test_print_default_output
    # assert_match(/To update this executable/, @stdout)
  end
  
  def xxx_test_help
    io = StringIO.new
    PVN::App::Runner.new io, %w{ --help }
    io.rewind
    io = io.read
    # assert_match(/To update this executable/, io)
  end
end
