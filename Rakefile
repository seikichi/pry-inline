# coding: UTF-8

require 'rake/testtask'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'

task default: [:test]

Rake::TestTask.new do |t|
  t.libs << 'test'
  t.ruby_opts = ['-r./test/helper']
  t.test_files = Dir['test/**/test_*.rb']
  t.verbose = true
end

RuboCop::RakeTask.new
