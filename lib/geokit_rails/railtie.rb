require 'geokit_rails'
require 'rails'

module Geokit

  class Railtie < Rails::Railtie
    initializer 'geokit_rails.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:include, Geokit::ActsAsMappable::Glue)
      end
    end
    initializer 'geokit_rails.insert_into_action_controller' do
      ActiveSupport.on_load :action_controller do
        ActionController::Base.send(:include, Geokit::GeocoderControl)
        ActionController::Base.send(:include, GeoKit::IpGeocodeLookup)
      end
    end
  end
  
end