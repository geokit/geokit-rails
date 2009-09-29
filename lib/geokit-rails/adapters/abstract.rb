module Geokit
  module Adapters
    class Abstract
      class NotImplementedError < StandardError ; end
      
      cattr_accessor :loaded
      
      class << self
        def load(klass) ; end
      end
      
      def initialize(klass)
        @owner = klass
      end
      
      def method_missing(method, *args, &block)
        return @owner.send(method, *args, &block) if @owner.respond_to?(method)
        super
      end
      
      def sphere_distance_sql(lat, lng, multiplier)
        raise NotImplementedError, '#sphere_distance_sql is not implemented'
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        raise NotImplementedError, '#flat_distance_sql is not implemented'
      end
      
    end
  end
end