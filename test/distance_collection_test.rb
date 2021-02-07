require 'test_helper'

Geokit::Geocoders::provider_order = [:google, :us]

class DistanceCollectionTest < GeokitTestCase

  LOCATION_A_IP = "217.10.83.5"

  def setup
    @location_a = Geokit::GeoLoc.new
    @location_a.lat = 32.918593
    @location_a.lng = -96.958444
    @location_a.city = "Irving"
    @location_a.state = "TX"
    @location_a.country_code = "US"
    @location_a.success = true

    @sw = Geokit::LatLng.new(32.91663,-96.982841)
    @ne = Geokit::LatLng.new(32.96302,-96.919495)
    @bounds_center=Geokit::LatLng.new((@sw.lat+@ne.lat)/2,(@sw.lng+@ne.lng)/2)

    @starbucks = companies(:starbucks)
    @loc_a = locations(:a)
    @custom_loc_a = custom_locations(:a)
    @loc_e = locations(:e)
    @custom_loc_e = custom_locations(:e)

    @barnes_and_noble = mock_organizations(:barnes_and_noble)
    @address = mock_addresses(:address_barnes_and_noble)
  end

  def test_distance_collection
    # Improve this test later on.
    locations            = Location.with_latlng.all
    unsorted             = [locations(:a), locations(:b), locations(:c), locations(:d), locations(:e), locations(:f)]
    sorted_manually      = locations.sort_by{|l| l.distance_to(locations(:a))}
    sorted_automatically = DistanceCollection.new(unsorted)
    sorted_automatically.set_distance_from(locations(:a))
    assert_equal sorted_manually, sorted_automatically.sort_by(&:distance)
  end

end