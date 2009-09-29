require 'rake/testtask'

desc 'Test the GeoKit plugin.'
Rake::TestTask.new(:test) do |t|
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
  t.libs << 'test'
end

class EnvTestTask < Rake::TestTask
  attr_accessor :env
  
  def ruby(*args)
    env.each { |key, value| ENV[key] = value } if env
    super
    env.keys.each { |key| ENV.delete(key) } if env
  end
  
end

%w(mysql postgresql sqlserver).each do |configuration|
  EnvTestTask.new("test_#{configuration}") do |t|
    t.pattern = 'test/**/*_test.rb'
    t.verbose = true
    t.env     = { 'DB' => configuration }
    t.libs << 'test'
  end
end

desc 'Test available databases.'
task :test_databases => %w(test_mysql test_postgresql test_sqlserver)