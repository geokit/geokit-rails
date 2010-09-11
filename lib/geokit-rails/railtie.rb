require 'geokit_rails'
require 'rails'

module Geokit

  class Railtie < Rails::Railtie
    initializer 'geokit_rails.insert_into_active_record' do
      ActiveSupport.on_load :active_record do
        ActiveRecord::Base.send(:include, Geokit::ActsAsMappable::Glue)
      end
    end
  end
  
end