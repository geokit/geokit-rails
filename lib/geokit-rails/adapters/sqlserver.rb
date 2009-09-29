module Geokit
  module Adapters
    class SQLServer < Abstract
      
      class << self
        
        def load(klass)
          klass.connection.execute <<-EOS
            if exists (select * from dbo.sysobjects where id = object_id(N'[dbo].[geokit_least]') and xtype in (N'FN', N'IF', N'TF'))
            drop function [dbo].[geokit_least]
          EOS

          klass.connection.execute <<-EOS
            CREATE FUNCTION [dbo].geokit_least (@value1 float,@value2 float) RETURNS float AS BEGIN
            return (SELECT CASE WHEN @value1 < @value2 THEN  @value1 ELSE @value2 END) END
          EOS
          self.loaded = true
        end
        
      end
      
      def initialize(*args)
        super(*args)
      end
      
      def sphere_distance_sql(lat, lng, multiplier)
        %|
          (ACOS([dbo].geokit_least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
          COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
          SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
         |
      end
      
      def flat_distance_sql(origin, lat_degree_units, lng_degree_units)
        %|
          SQRT(POWER(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
          POWER(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
         |
      end
      
    end
  end
end