module Geokit
  module ActsAsMappable

    # Add the +acts_as_mappable+ method into ActiveRecord subclasses
    module Glue # :nodoc:
      extend ActiveSupport::Concern

      module ClassMethods # :nodoc:
        OPTION_SYMBOLS = [ :distance_column_name, :default_units, :default_formula, :lat_column_name, :lng_column_name, :qualified_lat_column_name, :qualified_lng_column_name, :skip_loading ]

        def acts_as_mappable(options = {})
          metaclass = (class << self; self; end)

          include Geokit::ActsAsMappable

          cattr_accessor :through
          self.through = options[:through]

          if reflection = Geokit::ActsAsMappable.end_of_reflection_chain(self.through, self)
            metaclass.instance_eval do
              OPTION_SYMBOLS.each do |method_name|
                define_method method_name do
                  reflection.klass.send(method_name)
                end
              end
            end
          else
            cattr_accessor *OPTION_SYMBOLS

            self.distance_column_name = options[:distance_column_name]  || 'distance'
            self.default_units = options[:default_units] || Geokit::default_units
            self.default_formula = options[:default_formula] || Geokit::default_formula
            self.lat_column_name = options[:lat_column_name] || 'lat'
            self.lng_column_name = options[:lng_column_name] || 'lng'
            self.skip_loading = options[:skip_loading]
            self.qualified_lat_column_name = "#{table_name}.#{lat_column_name}"
            self.qualified_lng_column_name = "#{table_name}.#{lng_column_name}"

            if options.include?(:auto_geocode) && options[:auto_geocode]
              # if the form auto_geocode=>true is used, let the defaults take over by suppling an empty hash
              options[:auto_geocode] = {} if options[:auto_geocode] == true
              cattr_accessor :auto_geocode_field, :auto_geocode_error_message
              self.auto_geocode_field = options[:auto_geocode][:field] || 'address'
              self.auto_geocode_error_message = options[:auto_geocode][:error_message] || 'could not locate address'

              # set the actual callback here
              before_validation :auto_geocode_address, :on => :create
            end
          end
        end
      end
    end # Glue
  end
end
