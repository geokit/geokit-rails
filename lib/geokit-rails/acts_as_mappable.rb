require 'active_record'
require 'active_support/concern'

module Geokit
  module ActsAsMappable

    class UnsupportedAdapter < StandardError ; end

    #class Relation < ActiveRecord::Relation
    #  attr_accessor :distance_formula

    #  def where(opts, *rest)
    #    return self if opts.blank?
    #    relation = clone
    #    where_values = build_where(opts, rest)
    #    relation.where_values += substitute_distance_in_values(where_values)
    #    relation
    #  end

    #  def order(*args)
    #    return self if args.blank?
    #    relation = clone
    #    order_values = args.flatten
    #    relation.order_values += substitute_distance_in_values(order_values)
    #    relation
    #  end

    #private
    #  def substitute_distance_in_values(values)
    #    return values unless @distance_formula
    #    # substitute distance with the actual distance equation
    #    pattern = Regexp.new("\\b#{@klass.distance_column_name}\\b")
    #    values.map {|value| value.is_a?(String) ? value.gsub(pattern, @distance_formula) : value }
    #  end
    #end

    extend ActiveSupport::Concern

    included do
      include Geokit::Mappable
    end

    # this is the callback for auto_geocoding
    def auto_geocode_address
      address=self.send(auto_geocode_field).to_s
      geo=Geokit::Geocoders::MultiGeocoder.geocode(address)

      if geo.success
        self.send("#{lat_column_name}=", geo.send(:"#{lat_column_name}"))
        self.send("#{lng_column_name}=", geo.send(:"#{lng_column_name}"))
      else
        errors.add(auto_geocode_field, auto_geocode_error_message)
      end

      geo.success
    end

    def self.end_of_reflection_chain(through, klass)
      while through
        reflection = nil
        if through.is_a?(Hash)
          association, through = through.to_a.first
        else
          association, through = through, nil
        end

        if reflection = klass.reflect_on_association(association)
          klass = reflection.klass
        else
          raise ArgumentError, "You gave #{association} in :through, but I could not find it on #{klass}."
        end
      end

      reflection
    end

  end # ActsAsMappable
end # Geokit
