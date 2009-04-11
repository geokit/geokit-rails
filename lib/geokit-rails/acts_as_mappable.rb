module Geokit
  # Contains the class method acts_as_mappable targeted to be mixed into ActiveRecord.
  # When mixed in, augments find services such that they provide distance calculation
  # query services.  The find method accepts additional options:
  #
  # * :origin - can be 
  #   1. a two-element array of latititude/longitude -- :origin=>[37.792,-122.393]
  #   2. a geocodeable string -- :origin=>'100 Spear st, San Francisco, CA'
  #   3. an object which responds to lat and lng methods, or latitude and longitude methods,
  #      or whatever methods you have specified for lng_column_name and lat_column_name
  #
  # Other finder methods are provided for specific queries.  These are:
  #
  # * find_within (alias: find_inside)
  # * find_beyond (alias: find_outside)
  # * find_closest (alias: find_nearest)
  # * find_farthest
  #
  # Counter methods are available and work similarly to finders.  
  #
  # If raw SQL is desired, the distance_sql method can be used to obtain SQL appropriate
  # to use in a find_by_sql call.
  module ActsAsMappable 
    # Mix below class methods into ActiveRecord.
    def self.included(base) # :nodoc:
      base.extend ClassMethods
    end
    
    # Class method to mix into active record.
    module ClassMethods # :nodoc:
      # Class method to bring distance query support into ActiveRecord models.  By default
      # uses :miles for distance units and performs calculations based upon the Haversine
      # (sphere) formula.  These can be changed by setting Geokit::default_units and
      # Geokit::default_formula.  Also, by default, uses lat, lng, and distance for respective
      # column names.  All of these can be overridden using the :default_units, :default_formula,
      # :lat_column_name, :lng_column_name, and :distance_column_name hash keys.
      # 
      # Can also use to auto-geocode a specific column on create. Syntax;
      #   
      #   acts_as_mappable :auto_geocode=>true
      # 
      # By default, it tries to geocode the "address" field. Or, for more customized behavior:
      #   
      #   acts_as_mappable :auto_geocode=>{:field=>:address,:error_message=>'bad address'}
      #   
      # In both cases, it creates a before_validation_on_create callback to geocode the given column.
      # For anything more customized, we recommend you forgo the auto_geocode option
      # and create your own AR callback to handle geocoding.
      def acts_as_mappable(options = {})
        # Mix in the module, but ensure to do so just once.
        return if !defined?(Geokit::Mappable) || self.included_modules.include?(Geokit::ActsAsMappable::InstanceMethods)
        send :include, Geokit::ActsAsMappable::InstanceMethods
        # include the Mappable module.
        send :include, Geokit::Mappable
        
        # Handle class variables.
        cattr_accessor :through
        if self.through = options[:through]
          if reflection = self.reflect_on_association(self.through)
            (class << self; self; end).instance_eval do
              [ :distance_column_name, :default_units, :default_formula, :lat_column_name, :lng_column_name, :qualified_lat_column_name, :qualified_lng_column_name ].each do |method_name|
                define_method method_name do
                  reflection.klass.send(method_name)
                end
              end
            end
          end
        else
          cattr_accessor :distance_column_name, :default_units, :default_formula, :lat_column_name, :lng_column_name, :qualified_lat_column_name, :qualified_lng_column_name
          self.distance_column_name = options[:distance_column_name]  || 'distance'
          self.default_units = options[:default_units] || Geokit::default_units
          self.default_formula = options[:default_formula] || Geokit::default_formula
          self.lat_column_name = options[:lat_column_name] || 'lat'
          self.lng_column_name = options[:lng_column_name] || 'lng'
          self.qualified_lat_column_name = "#{table_name}.#{lat_column_name}"
          self.qualified_lng_column_name = "#{table_name}.#{lng_column_name}"
          if options.include?(:auto_geocode) && options[:auto_geocode]
            # if the form auto_geocode=>true is used, let the defaults take over by suppling an empty hash
            options[:auto_geocode] = {} if options[:auto_geocode] == true 
            cattr_accessor :auto_geocode_field, :auto_geocode_error_message
            self.auto_geocode_field = options[:auto_geocode][:field] || 'address'
            self.auto_geocode_error_message = options[:auto_geocode][:error_message] || 'could not locate address'
          
            # set the actual callback here
            before_validation_on_create :auto_geocode_address        
          end
        end
      end
    end
    
    # this is the callback for auto_geocoding
    def auto_geocode_address
      address=self.send(auto_geocode_field).to_s
      geo=Geokit::Geocoders::MultiGeocoder.geocode(address)
  
      if geo.success
        self.send("#{lat_column_name}=", geo.lat)
        self.send("#{lng_column_name}=", geo.lng)
      else
        errors.add(auto_geocode_field, auto_geocode_error_message) 
      end
      
      geo.success
    end
    
    # Instance methods to mix into ActiveRecord.
    module InstanceMethods #:nodoc:    
      # Mix class methods into module.
      def self.included(base) # :nodoc:
        base.extend SingletonMethods
      end
      
      # Class singleton methods to mix into ActiveRecord.
      module SingletonMethods # :nodoc:
        # Extends the existing find method in potentially two ways:
        # - If a mappable instance exists in the options, adds a distance column.
        # - If a mappable instance exists in the options and the distance column exists in the
        #   conditions, substitutes the distance sql for the distance column -- this saves
        #   having to write the gory SQL.
        def find(*args)
          prepare_for_find_or_count(:find, args)
          super(*args)
        end     
        
        # Extends the existing count method by:
        # - If a mappable instance exists in the options and the distance column exists in the
        #   conditions, substitutes the distance sql for the distance column -- this saves
        #   having to write the gory SQL.
        def count(*args)
          prepare_for_find_or_count(:count, args)
          super(*args)
        end
        
        # Finds within a distance radius.
        def find_within(distance, options={})
          options[:within] = distance
          find(:all, options)
        end
        alias find_inside find_within
                
        # Finds beyond a distance radius.
        def find_beyond(distance, options={})
          options[:beyond] = distance
          find(:all, options)
        end
        alias find_outside find_beyond
        
        # Finds according to a range.  Accepts inclusive or exclusive ranges.
        def find_by_range(range, options={})
          options[:range] = range
          find(:all, options)
        end
        
        # Finds the closest to the origin.
        def find_closest(options={})
          find(:nearest, options)
        end
        alias find_nearest find_closest
        
        # Finds the farthest from the origin.
        def find_farthest(options={})
          find(:farthest, options)
        end

        # Finds within rectangular bounds (sw,ne).
        def find_within_bounds(bounds, options={})
          options[:bounds] = bounds
          find(:all, options)
        end
        
        # counts within a distance radius.
        def count_within(distance, options={})
          options[:within] = distance
          count(options)
        end
        alias count_inside count_within

        # Counts beyond a distance radius.
        def count_beyond(distance, options={})
          options[:beyond] = distance
          count(options)
        end
        alias count_outside count_beyond
        
        # Counts according to a range.  Accepts inclusive or exclusive ranges.
        def count_by_range(range, options={})
          options[:range] = range
          count(options)
        end

        # Finds within rectangular bounds (sw,ne).
        def count_within_bounds(bounds, options={})
          options[:bounds] = bounds
          count(options)
        end
                
        # Returns the distance calculation to be used as a display column or a condition.  This
        # is provide for anyone wanting access to the raw SQL.
        def distance_sql(origin, units=default_units, formula=default_formula)
          case formula
          when :sphere
            sql = sphere_distance_sql(origin, units)
          when :flat
            sql = flat_distance_sql(origin, units)
          end
          sql
        end   

        private
        
        # Prepares either a find or a count action by parsing through the options and
        # conditionally adding to the select clause for finders.
        def prepare_for_find_or_count(action, args)
          options = args.extract_options!
          #options = defined?(args.extract_options!) ? args.extract_options! : extract_options_from_args!(args)
          # Obtain items affecting distance condition.
          origin = extract_origin_from_options(options)
          units = extract_units_from_options(options)
          formula = extract_formula_from_options(options)
          bounds = extract_bounds_from_options(options)
          # if no explicit bounds were given, try formulating them from the point and distance given
          bounds = formulate_bounds_from_distance(options, origin, units) unless bounds
          # Apply select adjustments based upon action.
          add_distance_to_select(options, origin, units, formula) if origin && action == :find
          # Apply the conditions for a bounding rectangle if applicable
          apply_bounds_conditions(options,bounds) if bounds
          # Apply distance scoping and perform substitutions.
          apply_distance_scope(options)
          substitute_distance_in_conditions(options, origin, units, formula) if origin && options.has_key?(:conditions)
          # Order by scoping for find action.
          apply_find_scope(args, options) if action == :find
          # Handle :through
          apply_include_for_through(options) if origin
          # Unfortunatley, we need to do extra work if you use an :include. See the method for more info.
          handle_order_with_include(options,origin,units,formula) if options.include?(:include) && options.include?(:order) && origin
          # Restore options minus the extra options that we used for the
          # Geokit API.
          args.push(options)   
        end
        
        def apply_include_for_through(options)
          if self.through
            case options[:include]
            when Array
              options[:include] << self.through
            when Hash, String, Symbol
              options[:include] = [ self.through, options[:include] ]
            else
              options[:include] = [ self.through ]
            end
          end
        end
        
        # If we're here, it means that 1) an origin argument, 2) an :include, 3) an :order clause were supplied.
        # Now we have to sub some SQL into the :order clause. The reason is that when you do an :include,
        # ActiveRecord drops the psuedo-column (specificically, distance) which we supplied for :select. 
        # So, the 'distance' column isn't available for the :order clause to reference when we use :include.
        def handle_order_with_include(options, origin, units, formula)
          # replace the distance_column_name with the distance sql in order clause
          options[:order].sub!(distance_column_name, distance_sql(origin, units, formula))
        end
        
        # Looks for mapping-specific tokens and makes appropriate translations so that the 
        # original finder has its expected arguments.  Resets the the scope argument to 
        # :first and ensures the limit is set to one.
        def apply_find_scope(args, options)
          case args.first
            when :nearest, :closest
              args[0] = :first
              options[:limit] = 1
              options[:order] = "#{distance_column_name} ASC"
            when :farthest
              args[0] = :first
              options[:limit] = 1
              options[:order] = "#{distance_column_name} DESC"
          end
        end
        
        # If it's a :within query, add a bounding box to improve performance.
        # This only gets called if a :bounds argument is not otherwise supplied. 
        def formulate_bounds_from_distance(options, origin, units)
          distance = options[:within] if options.has_key?(:within)
          distance = options[:range].last-(options[:range].exclude_end?? 1 : 0) if options.has_key?(:range)
          if distance
            res=Geokit::Bounds.from_point_and_radius(origin,distance,:units=>units)
          else 
            nil
          end
        end
        
        # Replace :within, :beyond and :range distance tokens with the appropriate distance 
        # where clauses.  Removes these tokens from the options hash.
        def apply_distance_scope(options)
          distance_condition = "#{distance_column_name} <= #{options[:within]}" if options.has_key?(:within)
          distance_condition = "#{distance_column_name} > #{options[:beyond]}" if options.has_key?(:beyond)
          distance_condition = "#{distance_column_name} >= #{options[:range].first} AND #{distance_column_name} <#{'=' unless options[:range].exclude_end?} #{options[:range].last}" if options.has_key?(:range)
          [:within, :beyond, :range].each { |option| options.delete(option) } if distance_condition
          
          options[:conditions]=augment_conditions(options[:conditions],distance_condition) if distance_condition
        end

        # This method lets you transparently add a new condition to a query without
        # worrying about whether it currently has conditions, or what kind of conditions they are
        # (string or array).
        # 
        # Takes the current conditions (which can be an array or a string, or can be nil/false), 
        # and a SQL string. It inserts the sql into the existing conditions, and returns new conditions
        # (which can be a string, an array, or a hash)
        def augment_conditions(current_conditions,sql)
          if current_conditions && current_conditions.is_a?(String)
            sql = ' AND ' + sql unless current_conditions.blank?
            res = current_conditions + sql   
          elsif current_conditions && current_conditions.is_a?(Array)
            cond_copy = current_conditions.dup
            cond_copy[0] ||= ''
            cond_copy[0] += " AND " unless cond_copy[0].blank? 
            cond_copy[0] += sql
            res = cond_copy
          elsif current_conditions && current_conditions.is_a?(Hash)
            res = "#{sanitize_sql_for_conditions(current_conditions)}" || ''
            res += ' AND ' unless res.blank?
            res += sql
          else
            res = sql
          end
          res
        end

        # Alters the conditions to include rectangular bounds conditions.
        def apply_bounds_conditions(options,bounds)
          sw,ne=bounds.sw,bounds.ne
          lng_sql= bounds.crosses_meridian? ? "(#{qualified_lng_column_name}<#{ne.lng} OR #{qualified_lng_column_name}>#{sw.lng})" : "#{qualified_lng_column_name}>#{sw.lng} AND #{qualified_lng_column_name}<#{ne.lng}"
          bounds_sql="#{qualified_lat_column_name}>#{sw.lat} AND #{qualified_lat_column_name}<#{ne.lat} AND #{lng_sql}"
          options[:conditions]=augment_conditions(options[:conditions],bounds_sql)          
        end

        # Extracts the origin instance out of the options if it exists and returns
        # it.  If there is no origin, looks for latitude and longitude values to 
        # create an origin.  The side-effect of the method is to remove these 
        # option keys from the hash.
        def extract_origin_from_options(options)
          origin = options.delete(:origin)
          res = normalize_point_to_lat_lng(origin) if origin
          res
        end
        
        # Extract the units out of the options if it exists and returns it.  If
        # there is no :units key, it uses the default.  The side effect of the 
        # method is to remove the :units key from the options hash.
        def extract_units_from_options(options)
          units = options[:units] || default_units
          options.delete(:units)
          units
        end
        
        # Extract the formula out of the options if it exists and returns it.  If
        # there is no :formula key, it uses the default.  The side effect of the 
        # method is to remove the :formula key from the options hash.
        def extract_formula_from_options(options)
          formula = options[:formula] || default_formula
          options.delete(:formula)
          formula
        end
        
        def extract_bounds_from_options(options)
          bounds = options.delete(:bounds)
          bounds = Geokit::Bounds.normalize(bounds) if bounds
        end
       
        # Geocode IP address.
        def geocode_ip_address(origin)
          geo_location = Geokit::Geocoders::IpGeocoder.geocode(origin)
          return geo_location if geo_location.success
          raise Geokit::Geocoders::GeocodeError
        end
        

        # Given a point in a variety of (an address to geocode,
        # an array of [lat,lng], or an object with appropriate lat/lng methods, an IP addres)
        # this method will normalize it into a Geokit::LatLng instance. The only thing this
        # method adds on top of LatLng#normalize is handling of IP addresses
        def normalize_point_to_lat_lng(point)
          res = geocode_ip_address(point) if point.is_a?(String) && /^(\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})?$/.match(point)
          res = Geokit::LatLng.normalize(point) unless res
          res       
        end

        # Augments the select with the distance SQL.
        def add_distance_to_select(options, origin, units=default_units, formula=default_formula)
          if origin
            distance_selector = distance_sql(origin, units, formula) + " AS #{distance_column_name}"
            selector = options.has_key?(:select) && options[:select] ? options[:select] : "*"
            options[:select] = "#{selector}, #{distance_selector}"  
          end
        end

        # Looks for the distance column and replaces it with the distance sql. If an origin was not 
        # passed in and the distance column exists, we leave it to be flagged as bad SQL by the database.
        # Conditions are either a string or an array.  In the case of an array, the first entry contains
        # the condition.
        def substitute_distance_in_conditions(options, origin, units=default_units, formula=default_formula)
          original_conditions = options[:conditions]
          condition = original_conditions.is_a?(String) ? original_conditions : original_conditions.first
          pattern = Regexp.new("\\b#{distance_column_name}\\b")
          condition = condition.gsub(pattern, distance_sql(origin, units, formula))
          original_conditions = condition if original_conditions.is_a?(String)
          original_conditions[0] = condition if original_conditions.is_a?(Array)
          options[:conditions] = original_conditions
        end
        
        # Returns the distance SQL using the spherical world formula (Haversine).  The SQL is tuned
        # to the database in use.
        def sphere_distance_sql(origin, units)
          lat = deg2rad(origin.lat)
          lng = deg2rad(origin.lng)
          multiplier = units_sphere_multiplier(units)
          case connection.adapter_name.downcase
          when "mysql"
            sql=<<-SQL_END 
                  (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
                  COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
                  SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
                  SQL_END
          when "postgresql"
            sql=<<-SQL_END 
                  (ACOS(least(1,COS(#{lat})*COS(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*COS(RADIANS(#{qualified_lng_column_name}))+
                  COS(#{lat})*SIN(#{lng})*COS(RADIANS(#{qualified_lat_column_name}))*SIN(RADIANS(#{qualified_lng_column_name}))+
                  SIN(#{lat})*SIN(RADIANS(#{qualified_lat_column_name}))))*#{multiplier})
                  SQL_END
          else
            sql = "unhandled #{connection.adapter_name.downcase} adapter"
          end        
        end
        
        # Returns the distance SQL using the flat-world formula (Phythagorean Theory).  The SQL is tuned
        # to the database in use.
        def flat_distance_sql(origin, units)
          lat_degree_units = units_per_latitude_degree(units)
          lng_degree_units = units_per_longitude_degree(origin.lat, units)
          case connection.adapter_name.downcase
          when "mysql"
            sql=<<-SQL_END
                  SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
                  POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
                  SQL_END
          when "postgresql"
            sql=<<-SQL_END
                  SQRT(POW(#{lat_degree_units}*(#{origin.lat}-#{qualified_lat_column_name}),2)+
                  POW(#{lng_degree_units}*(#{origin.lng}-#{qualified_lng_column_name}),2))
                  SQL_END
          else
            sql = "unhandled #{connection.adapter_name.downcase} adapter"
          end
        end
      end
    end
  end
end

# Extend Array with a sort_by_distance method.
# This method creates a "distance" attribute on each object, 
# calculates the distance from the passed origin,
# and finally sorts the array by the resulting distance.
class Array
  def sort_by_distance_from(origin, opts={})
    distance_attribute_name = opts.delete(:distance_attribute_name) || 'distance'    
    self.each do |e|
      e.class.send(:attr_accessor, distance_attribute_name) if !e.respond_to? "#{distance_attribute_name}="
      e.send("#{distance_attribute_name}=", e.distance_to(origin,opts))
    end
    self.sort!{|a,b|a.send(distance_attribute_name) <=> b.send(distance_attribute_name)}
  end
end
