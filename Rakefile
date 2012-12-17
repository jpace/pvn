require 'rubygems'
require 'riel'
require 'rake/testtask'
require 'rubygems/package_task'
require 'fileutils'
require './test/unit/resources'

Dir['tasks/**/*.rake'].each { |t| load t }

task :default => 'test:unit'

class PVNTestTask < Rake::TestTask
  def initialize name, pattern
    super name do |t|
      t.libs << 'lib'
      t.libs << 'test'
      t.libs << 'test/unit'
      t.pattern = 'test/' + pattern
      t.warning = true
      t.verbose = true
    end
  end
end

PVNTestTask.new 'test:unit', 'unit/**/*_test.rb'
PVNTestTask.new 'test:integration', 'integration/**/*_test.rb'
PVNTestTask.new 'test:all', '**/*_test.rb'

task :build_fixtures do
  Resources.instance.generate
end

spec = Gem::Specification.new do |s| 
  s.name               = "pvn"
  s.version            = "0.0.13"
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
  s.add_dependency("riel", ">= 1.1.16")
  s.add_dependency("rainbow", ">= 1.1.4")
  s.bindir             = 'bin'
  s.executables        = %w{ pvn pvndiff }
  s.default_executable = 'pvn'
end
 
Gem::PackageTask.new(spec) do |pkg| 
  pkg.need_zip = true 
  pkg.need_tar_gz = true 
end 
