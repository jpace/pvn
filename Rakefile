require 'rubygems'
require 'riel'
require 'rake/testtask'
require 'fileutils'

require './lib/pvn'

Dir['tasks/**/*.rake'].each { |t| load t }

class PvnTestTask < Rake::TestTask
  def initialize name = 'test'
    super

    libs << "lib"
    libs << "test"
    libs << "test/unit"
    libs << "test/integration"
    warning = true
    verbose = true
  end
end

PvnTestTask.new do |t|
  t.test_files = FileList['test/unit/test*.rb']
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
