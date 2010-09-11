# Extend Array with a sort_by_distance method.
class Array
  # This method creates a "distance" attribute on each object, calculates the
  # distance from the passed origin, and finally sorts the array by the
  # resulting distance.
  def sort_by_distance_from(origin, opts={})
    distance_attribute_name = opts.delete(:distance_attribute_name) || 'distance'
    self.each do |e|
      e.class.send(:attr_accessor, distance_attribute_name) if !e.respond_to?("#{distance_attribute_name}=")
      e.send("#{distance_attribute_name}=", e.distance_to(origin,opts))
    end
    self.sort!{|a,b|a.send(distance_attribute_name) <=> b.send(distance_attribute_name)}
  end
end