module Geokit
  module Adapters
    class PostgreSQL < Abstract
      
      def sphere_distance_sql(lat, lng, multiplier)
        lat = "CAST(#{lat} AS FLOAT)"
        lng = "CAST(#{lng} AS FLOAT)"
        qualified_lat_column_name = "CAST(#{qualified_lat_column_name} AS FLOAT)" unless qualified_lat_column_name.nil?
        qualified_lng_column_name = "CAST(#{qualified_lng_column_name} AS FLOAT)" unless qualified_lng_column_name.nil?
        %|
          (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
          COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
          SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
         |
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        lat_degree_units = "CAST(#{lat_degree_units} AS FLOAT)"
        lng_degree_units = "CAST(#{lng_degree_units} AS FLOAT)"
        qualified_lat_column_name = "CAST(#{qualified_lat_column_name} AS FLOAT)"
        qualified_lng_column_name = "CAST(#{qualified_lng_column_name} AS FLOAT)"
        %|
          SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
          POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
         |
      end
      
    end
  end
end