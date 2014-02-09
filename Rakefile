require 'rake/testtask'

desc "Default Task"
task :default => :test

Rake::TestTask.new do |t|
  t.test_files = FileList['test/test_*.rb']
  t.libs << "."
  t.verbose = true
end