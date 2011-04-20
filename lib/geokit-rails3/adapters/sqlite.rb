module Geokit
  module Adapters
    class SQLite < Abstract
      
      def self.add_numeric(name) 
        @@connection.create_function name, 1, :numeric do |func, *args|
          func.result = yield(*args)
        end
      end

      def self.add_math(name)
        add_numeric name do |*n|
          Math.send name, *n
        end
      end
      
      class << self
        def load(klass)
          @@connection = klass.connection.raw_connection
          # Define the functions needed
          add_math 'sqrt'
          add_math 'cos'
          add_math 'acos'
          add_math 'sin'

          add_numeric('pow') { |n, m| n**m }
          add_numeric('radians') { |n| n * Math::PI / 180 }
          add_numeric('least') { |*args| args.min }
        end
      end
      
      def sphere_distance_sql(lat, lng, multiplier)
        %|
          (CASE WHEN #{qualified_lat_column_name} IS NULL OR #{qualified_lng_column_name} IS NULL THEN NULL ELSE
          (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
          COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
          SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
          END)
         |
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %|
          (CASE WHEN #{qualified_lat_column_name} IS NULL OR #{qualified_lng_column_name} IS NULL THEN NULL ELSE
          SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
          POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
          END)
         |
      end
      
    end
  end
end