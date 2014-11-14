module Geokit
  module Adapters
    class OracleEnhanced < Abstract
      TO_DEGREES = Math::PI / 180
      def sphere_distance_sql(lat, lng, multiplier)
        %{
(
  ACOS(
    COS(#{lat}) * COS(#{lng}) *
    COS(#{TO_DEGREES} * #{qualified_lat_column_name}) *
    COS(#{TO_DEGREES} * #{qualified_lng_column_name}) +
    COS(#{lat}) * SIN(#{lng}) *
    COS(#{TO_DEGREES} * #{qualified_lat_column_name}) *
    SIN(#{TO_DEGREES} * #{qualified_lng_column_name}) +
    SIN(#{lat}) *
    SIN(#{TO_DEGREES} * #{qualified_lat_column_name})
  ) *
  #{multiplier})
}
      end

      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %{
SQRT(
  POWER(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}), 2)
  POWER(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}), 2)
)
         }
      end
    end
  end
end
