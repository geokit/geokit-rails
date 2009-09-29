# Load modules and classes needed to automatically mix in ActiveRecord and 
# ActionController helpers.  All other functionality must be explicitly 
# required.
#
# Note that we don't explicitly require the geokit gem. 
# You should specify gem dependencies in your config/environment.rb: config.gem "geokit"
#
if defined? Geokit
  require 'geokit-rails/defaults'
  require 'geokit-rails/adapters/abstract'
  require 'geokit-rails/acts_as_mappable'
  require 'geokit-rails/ip_geocode_lookup'
  
  # Automatically mix in distance finder support into ActiveRecord classes.
  ActiveRecord::Base.send :include, GeoKit::ActsAsMappable
  
  # Automatically mix in ip geocoding helpers into ActionController classes.
  ActionController::Base.send :include, GeoKit::IpGeocodeLookup
else
  message=%q(WARNING: geokit-rails requires the Geokit gem. You either don't have the gem installed,
or you haven't told Rails to require it. If you're using a recent version of Rails: 
  config.gem "geokit" # in config/environment.rb
and of course install the gem: sudo gem install geokit)
  puts message
  Rails.logger.error message
end