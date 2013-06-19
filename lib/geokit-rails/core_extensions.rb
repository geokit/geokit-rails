# Extend Array with a sort_by_distance method.
class Array
  # This method creates a "distance" attribute on each object, calculates the
  # distance from the passed origin, and finally sorts the array by the
  # resulting distance.
  def sort_by_distance_from(origin, opts={})
    warn "[DEPRECATION] `Array#sort_by_distance_from(origin, opts)` is deprecated. Please use Array#sort_by{|e| e.distance_to(origin, opts)} instead which is not destructive"
    self[0..-1] = sort_by{|e| e.distance_to(origin, opts)}
  end
end