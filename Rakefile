require 'rubygems'
require 'riel'
require 'rake/testtask'
require 'rubygems/package_task'
require 'fileutils'

require './lib/pvn'
require './test/unit/resources'

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
  t.test_files = FileList['test/unit/**/*test*.rb']
end

PvnTestTask.new('test:integration') do |t|
  t.test_files = FileList['test/integration/**/*test*.rb']
end

PvnTestTask.new('test:all') do |t|
  t.test_files = FileList['test/**/*test*.rb']
end

task :build_fixtures do
  Resources.instance.generate
end

spec = Gem::Specification.new do |s| 
  s.name               = "pvn"
  s.version            = "0.0.9"
  s.author             = "Jeff Pace"
  s.email              = "jeugenepace@gmail.com"
  s.homepage           = "http://www.incava.org/projects/pvn"
  s.platform           = Gem::Platform::RUBY
  s.summary            = "What Subversion should have."
  s.description        = "A set of extensions to the Subversion command line, inspired by Git and Perforce."
  s.files              = FileList["{bin,lib}/**/*"].to_a
  s.require_path       = "lib"
  s.test_files         = FileList["{test}/**/*test.rb"].to_a
  s.has_rdoc           = false
  s.extra_rdoc_files   = ["README.markdown"]
  s.add_dependency("riel", ">= 1.1.6")
  s.bindir             = 'bin'
  s.executables        = %w{ pvn pvndiff }
  s.default_executable = 'pvn'
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
