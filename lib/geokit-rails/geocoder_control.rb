require 'active_support/concern'

module Geokit
  module GeocoderControl
    extend ActiveSupport::Concern

    included do
      if respond_to? :before_action
        send :before_action, :set_geokit_domain
      elsif respond_to? :before_filter
        send :before_filter, :set_geokit_domain
      end
    end

    def set_geokit_domain
      Geokit::Geocoders::domain = request.domain
    end
  end
end
