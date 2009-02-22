# Load modules and classes needed to automatically mix in ActiveRecord and 
# ActionController helpers.  All other functionality must be explicitly 
# required.
#
# Note that we don't explicitly require the geokit gem. You should specify gem dependencies in your config/environment.rb
#  with this line:   config.gem "andre-geokit", :lib=>'geokit', :source => 'http://gems.github.com'
#
if defined? Geokit
  require 'geokit-rails/defaults'
  require 'geokit-rails/acts_as_mappable'
  require 'geokit-rails/ip_geocode_lookup'
  
  # Automatically mix in distance finder support into ActiveRecord classes.
  ActiveRecord::Base.send :include, GeoKit::ActsAsMappable
  
  # Automatically mix in ip geocoding helpers into ActionController classes.
  ActionController::Base.send :include, GeoKit::IpGeocodeLookup
end