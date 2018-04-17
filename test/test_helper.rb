require 'pathname'

require 'boot'
require 'mocha/setup'

unless ENV['COVERAGE'] == 'off'
  COVERAGE_THRESHOLD = 35
  require 'simplecov'
  require 'simplecov-rcov'
  require 'coveralls'
  Coveralls.wear!

  SimpleCov.formatters = [
    SimpleCov::Formatter::RcovFormatter,
    Coveralls::SimpleCov::Formatter
  ]
  SimpleCov.start do
    add_filter '/test/'
    add_group 'lib', 'lib'
  end
  SimpleCov.at_exit do
    SimpleCov.result.format!
    percent = SimpleCov.result.covered_percent
    unless percent >= COVERAGE_THRESHOLD
      puts "Coverage must be above #{COVERAGE_THRESHOLD}%. It is #{"%.2f" % percent}%"
      Kernel.exit(1)
    end
  end
end

require 'geokit'
require 'geokit-rails'

ActiveRecord::Base.send(:include, Geokit::ActsAsMappable::Glue)
ActionController::Base.send(:include, Geokit::GeocoderControl)
ActionController::Base.send(:include, Geokit::IpGeocodeLookup)
# Rails >= 4 requires models classes to be loaded before fixtures are created
Dir[PLUGIN_ROOT + "test/models/*.rb"].each { |file| require file }

class GeokitTestCase < ActiveSupport::TestCase
  begin
    include ActiveRecord::TestFixtures
  rescue NameError
    puts "You appear to be using a pre-2.3 version of Rails. No need to include ActiveRecord::TestFixtures."
  end
  
  self.fixture_path = (PLUGIN_ROOT + 'test/fixtures').to_s
  if Rails::VERSION::MAJOR >= 5
    self.use_transactional_tests = true
  else
    self.use_transactional_fixtures = true
  end
  self.use_instantiated_fixtures  = false
  
  fixtures :all 
end
