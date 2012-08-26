require 'tc'
require 'pvn/app'

class TestPVNCli < PVN::TestCase
  def setup
    PVN::App::Runner.execute @stdout_io = StringIO.new, Array.new
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  def test_print_default_output
    # assert_match(/To update this executable/, @stdout)
  end
  
  def xxx_test_help
    io = StringIO.new
    PVN::App::Runner.execute io, %w{ --help }
    io.rewind
    io = io.read
    # assert_match(/To update this executable/, io)
  end
end
