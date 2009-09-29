require 'rubygems'
require 'mocha'

require 'boot'

require 'geokit'
require 'geokit-rails'


class GeokitTestCase < ActiveSupport::TestCase
  begin
    include ActiveRecord::TestFixtures
  rescue NameError
    puts "You appear to be using a pre-2.3 version of Rails. No need to include ActiveRecord::TestFixtures."
  end
  
  self.fixture_path = File.join(File.dirname(__FILE__), 'fixtures')
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false
  
  fixtures :all
  
end
