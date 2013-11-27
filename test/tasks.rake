require 'rake/testtask'

class EnvTestTask < Rake::TestTask
  attr_accessor :env
  
  def ruby(*args)
    env.each { |key, value| ENV[key] = value } if env
    super
    env.keys.each { |key| ENV.delete(key) } if env
  end
  
end

desc 'Test the Geokit plugin.'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/*_test.rb'
  test.verbose = true
end

%w(mysql postgresql sqlserver sqlite).each do |configuration|
  EnvTestTask.new("test_#{configuration}") do |t|
    t.pattern = 'test/*_test.rb'
    t.verbose = true
    t.env     = { 'DB' => configuration }
    t.libs << 'test'
  end
end

desc 'Test available databases.'
task :test_databases => %w(test_mysql test_postgresql test_sqlserver test_sqlite)

desc "Generate SimpleCov test coverage and open in your browser"
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].invoke
end
