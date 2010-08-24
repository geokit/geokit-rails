require 'active_support'
require 'active_support/test_case'

require 'active_record'
require 'active_record/fixtures'

require 'action_controller'
require 'action_dispatch'
require 'action_dispatch/testing/test_process'

PLUGIN_ROOT = File.join(File.dirname(__FILE__), '..')
ADAPTER = ENV['DB'] || 'mysql'

$LOAD_PATH << File.join(PLUGIN_ROOT, 'lib') << File.join(PLUGIN_ROOT, 'test', 'models')

FIXTURES_PATH = File.join(PLUGIN_ROOT, 'test', 'fixtures')
ActiveRecord::Base.configurations = config = YAML::load(IO.read(File.join(PLUGIN_ROOT, 'test', 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(PLUGIN_ROOT, 'test', "#{ADAPTER}-debug.log"))
ActiveRecord::Base.establish_connection(config[ADAPTER])

ActiveRecord::Migration.verbose = false
load File.join(PLUGIN_ROOT, 'test', 'schema.rb')