require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

load 'test/tasks.rake'

desc 'Default: run unit tests.'
task :default => :test

desc 'Generate documentation for the GeoKit plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'GeoKit'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

