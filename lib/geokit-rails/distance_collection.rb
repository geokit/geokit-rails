class DistanceCollection < Array
  def set_distance_from(origin, opts={})
    distance_attribute_name = opts.delete(:distance_attribute_name) || 'distance'
    klass = first.class
    klass.send(:attr_accessor, distance_attribute_name) if !klass.respond_to?("#{distance_attribute_name}=")
    each{|e| e.send("#{distance_attribute_name}=", e.distance_to(origin,opts)) }
  end
end
