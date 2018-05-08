module Geokit
  module Adapters
    class PostgreSQL < Abstract
      
      def sphere_distance_sql(lat, lng, multiplier)
        %|
          (ACOS(least(1,COS(CAST(#{lat} AS FLOAT))*COS(CAST(#{lng} AS FLOAT))*COS(RADIANS(CAST(#{qualified_lat_column_name} AS FLOAT)))*
          COS(RADIANS(CAST(#{qualified_lng_column_name} AS FLOAT)))+
          COS(CAST(#{lat} AS FLOAT))*SIN(CAST(#{lng} AS FLOAT))*COS(RADIANS(CAST(#{qualified_lat_column_name} AS FLOAT)))*
          SIN(RADIANS(CAST(#{qualified_lng_column_name} AS FLOAT)))+
          SIN(CAST(#{lat} AS FLOAT))*SIN(RADIANS(CAST(#{qualified_lat_column_name} AS FLOAT)))))*#{multiplier})
         |
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %|
          SQRT(POW(CAST(#{lat_degree_units} AS FLOAT)*(CAST(#{origin.lat} AS FLOAT)-CAST(#{qualified_lat_column_name} AS FLOAT)),2)+
          POW(CAST(#{lng_degree_units} AS FLOAT)*(CAST(#{origin.lng} AS FLOAT)-CAST(#{qualified_lng_column_name} AS FLOAT)),2))
         |
      end
      
    end
  end
end