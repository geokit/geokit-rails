require 'active_support'
require 'active_support/test_case'

require 'test/unit'
require 'test/unit/testcase'
require 'active_support/testing/setup_and_teardown'

require 'active_record'
require 'active_record/fixtures'

require 'action_controller'
require 'action_controller/test_process'

PLUGIN_ROOT = File.join(File.dirname(__FILE__), '..')
ADAPTER = ENV['DB'] || 'mysql'

$LOAD_PATH << File.join(PLUGIN_ROOT, 'lib') << File.join(PLUGIN_ROOT, 'test', 'models')

FIXTURES_PATH = File.join(PLUGIN_ROOT, 'test', 'fixtures')
ActiveRecord::Base.configurations = config = YAML::load(IO.read(File.join(PLUGIN_ROOT, 'test', 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(PLUGIN_ROOT, 'test', "#{ADAPTER}-debug.log"))
ActiveRecord::Base.establish_connection(config[ADAPTER])

ActiveRecord::Migration.verbose = false
load File.join(PLUGIN_ROOT, 'test', 'schema.rb')