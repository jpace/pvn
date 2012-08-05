require 'rubygems'
require 'riel'
require 'rake/testtask'
require 'rubygems/package_task'
require 'fileutils'

require './lib/pvn'

Dir['tasks/**/*.rake'].each { |t| load t }

class PvnTestTask < Rake::TestTask
  def initialize name = 'test'
    super

    libs << "lib"
    libs << "test"
    libs << "test/unit"
    # libs << "test/integration"
    warning = true
    verbose = true
  end
end

PvnTestTask.new do |t|
  t.test_files = FileList['test/unit/**/test*.rb']
end

PvnTestTask.new('test:integration') do |t|
  t.test_files = FileList['test/integration/**/test*.rb']
end

PvnTestTask.new('test:all') do |t|
  t.test_files = FileList['test/**/test*.rb']
end

def build_fixture svndir, svncmd
  origdir  = Pathname.new(Dir.pwd).expand_path
  tgtdir   = origdir + 'test/resources'
  outfname = svndir.sub(%r{^/}, '').gsub('/', '_') + '__' + svncmd.gsub(' ', '_')
  outfile  = tgtdir + outfname

  Dir.chdir svndir

  puts "svndir : #{svndir}"
  puts "svncmd : #{svncmd}"
  puts "outfile: #{outfile}"

  IO.popen(svncmd) do |io|
    lines = io.readlines
    File.open(outfile, "w") do |io|
      io.puts lines
    end
  end
  Dir.chdir origdir.to_s
end

task :build_fixtures do
  build_fixture '/Programs/wiquery', 'svn log -l 15 --xml'
  build_fixture '/Programs/wiquery', 'svn log --xml'
end

spec = Gem::Specification.new do |s| 
  s.name             = "pvn"
  s.version          = "0.0.1"
  s.author           = "Jeff Pace"
  s.email            = "jeugenepace@gmail.com"
  s.homepage         = "http://www.incava.org/projects/pvn"
  s.platform         = Gem::Platform::RUBY
  s.summary          = "What you wish Subversion had."
  s.files            = FileList["{bin,lib}/**/*"].to_a
  s.require_path     = "lib"
  s.test_files       = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc         = true
  s.extra_rdoc_files = [ "README.rdoc" ]
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
