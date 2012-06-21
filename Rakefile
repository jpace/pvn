require 'rubygems'
require 'riel'
require 'rake/testtask'
require 'fileutils'
require 'rake/testtask'

require './lib/pvn'

Dir['tasks/**/*.rake'].each { |t| load t }

class PvnTestTask < Rake::TestTask
  def initialize name = 'test'
    super

    libs << "lib"
    libs << "test"
    warning = true
    verbose = true
  end
end

PvnTestTask.new do |t|
  t.test_files = FileList['test/**/test*.rb'].exclude("test/integration/**")
end

PvnTestTask.new('test:integration') do |t|
  t.test_files = FileList['test/integration/**/test*.rb']
end

PvnTestTask.new('test:all') do |t|
  t.test_files = FileList['test/**/test*.rb']
end

task :build_fixtures do
  raise "not implemented"
end
