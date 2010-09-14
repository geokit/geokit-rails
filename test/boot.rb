require 'pathname'

require 'active_support'
require 'active_support/test_case'

require 'active_record'
require 'active_record/fixtures'

require 'action_controller'
require 'action_dispatch'
require 'action_dispatch/testing/test_process'

pwd = Pathname.new(File.dirname(__FILE__)).expand_path
PLUGIN_ROOT = pwd + '..'
ADAPTER = ENV['DB'] || 'mysql'

config_file = PLUGIN_ROOT + 'test/database.yml'
db_config   = YAML::load(IO.read(config_file))
logger_file = PLUGIN_ROOT + "test/#{ADAPTER}-debug.log"
schema_file = PLUGIN_ROOT + 'test/schema.rb'

ActiveRecord::Base.configurations = db_config
ActiveRecord::Base.logger = Logger.new(logger_file)
ActiveRecord::Base.establish_connection(db_config[ADAPTER])

ActiveRecord::Migration.verbose = false
load schema_file