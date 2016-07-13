require 'active_support/concern'

module Geokit
  module GeocoderControl
    extend ActiveSupport::Concern

    included do
      ActiveSupport::Deprecation.silence do
        if self.respond_to? :before_action
          self.send :before_action, :set_geokit_domain
        elsif self.respond_to? :before_filter
          self.send :before_filter, :set_geokit_domain
        end
      end
    end

    def set_geokit_domain
      Geokit::Geocoders::domain = request.domain
      logger.debug("Geokit is using the domain: #{Geokit::Geocoders::domain}")
    end
  end
end
