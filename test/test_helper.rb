ENV["RAILS_ENV"] = "test"
require "test/unit"
require "rubygems"
#require File.dirname(__FILE__) + '/../init'
require 'geokit'

plugin_test_dir = File.dirname(__FILE__)

# Load the Rails environment
require ENV['environment'] || File.join(plugin_test_dir, '../../../../config/environment')
require 'test_help'
#require 'active_record/fixtures'
databases = YAML::load(IO.read(plugin_test_dir + '/database.yml'))
ActiveRecord::Base.logger = Logger.new(plugin_test_dir + "/debug.log")

# A specific database can be used by setting the DB environment variable
ActiveRecord::Base.establish_connection(databases[ENV['DB'] || 'mysql'])

# Load the test schema into the database
load(File.join(plugin_test_dir, 'schema.rb'))

# Load fixtures from the plugin
#Test::Unit::TestCase.fixture_path = File.join(plugin_test_dir, 'fixtures/')
