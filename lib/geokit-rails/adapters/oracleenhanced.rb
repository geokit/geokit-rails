module Geokit
  module Adapters
    class OracleEnhanced < Abstract

      def sphere_distance_sql(lat, lng, multiplier)
        lat = rad2deg(lat)
        lng = rad2deg(lng)

        %|
        (2 * (#{multiplier} * ATAN2(
          SQRT(
            POWER(SIN((0.017453293 * (#{lat} - #{qualified_lat_column_name} ) ) / 2 ), 2 ) +
            COS(0.017453293 * (#{qualified_lat_column_name})) *
            COS(0.017453293 * (#{lat})) *
            POWER(SIN((0.017453293 * (#{lng} - #{qualified_lng_column_name} ) ) / 2 ), 2 )
          ),
          SQRT(1-(
            POWER(SIN((0.017453293 * (#{lat} - #{qualified_lat_column_name} ) ) / 2 ), 2 ) +
            COS(0.017453293 * (#{qualified_lat_column_name})) *
            COS(0.017453293 * (#{lat})) *
            POWER(SIN((0.017453293 * (#{lng} - #{qualified_lng_column_name} ) ) / 2 ), 2 )
          ))
        )))
|
      end

      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %|
          SQRT(POWER(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
          POWER(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
         |
      end


      private
      def rad2deg(value)
        (value / Math::PI)*180
      end
    end
  end
end
