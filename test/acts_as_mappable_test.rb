require 'test_helper'

Geokit::Geocoders::provider_order = [:google, :us]

class ActsAsMappableTest < GeokitTestCase

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

  def test_override_default_units_the_hard_way
    Location.default_units = :kms
    #locations = Location.geo_scope(:origin => @loc_a).where("distance < 3.97")
    locations = Location.within(3.9, :origin => @loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
    Location.default_units = :miles
  end

  def test_include
    #locations = Location.geo_scope(:origin => @loc_a).includes(:company).where("company_id = 1").all
    locations = Location.includes(:company).where("company_id = 1").to_a
    assert !locations.empty?
    assert_equal 1, locations[0].company.id
    assert_equal 'Starbucks', locations[0].company.name
  end

  def test_distance_between_geocoded
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("Irving, TX").returns(@location_a)
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("San Francisco, CA").returns(@location_a)
    assert_equal 0, Location.distance_between("Irving, TX", "San Francisco, CA")
  end

  def test_distance_to_geocoded
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("Irving, TX").returns(@location_a)
    assert_equal 0, @custom_loc_a.distance_to("Irving, TX")
  end

  def test_distance_to_geocoded_error
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("Irving, TX").returns(Geokit::GeoLoc.new)
    assert_raise(Geokit::Geocoders::GeocodeError) { @custom_loc_a.distance_to("Irving, TX")  }
  end

  def test_custom_attributes_distance_calculations
    assert_equal 0, @custom_loc_a.distance_to(@loc_a)
    assert_equal 0, CustomLocation.distance_between(@custom_loc_a, @loc_a)
  end

  def test_distance_column_in_select
    #locations = Location.geo_scope(:origin => @loc_a).order("distance ASC")
    locations = Location.by_distance(:origin => @loc_a)
    assert_equal 6, locations.to_a.size
    assert_equal 0, @loc_a.distance_to(locations.first)
    assert_in_delta 3.97, @loc_a.distance_to(locations.last, :units => :miles, :formula => :sphere), 0.01
  end

  def test_find_with_distance_condition
    #locations = Location.geo_scope(:origin => @loc_a, :within => 3.97)
    locations = Location.within(3.97, :origin => @loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_with_distance_condition_with_units_override
    #locations = Location.geo_scope(:origin => @loc_a, :units => :kms, :within => 6.387)
    locations = Location.within(6.387, :origin => @loc_a, :units => :kms)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_with_distance_condition_with_formula_override
    #locations = Location.geo_scope(:origin => @loc_a, :formula => :flat, :within => 6.387)
    locations = Location.within(6.387, :origin => @loc_a, :formula => :flat)
    assert_equal 6, locations.to_a.size
    assert_equal 6, locations.count
  end

  def test_find_within
    locations = Location.within(3.97, :origin => @loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_within_with_coordinates
    locations = Location.within(3.97, :origin =>[@loc_a.lat,@loc_a.lng])
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_with_compound_condition
    #locations = Location.geo_scope(:origin => @loc_a).where("distance < 5 and city = 'Coppell'")
    locations = Location.within(5, :origin => @loc_a).where("city = 'Coppell'")
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_with_secure_compound_condition
    #locations = Location.geo_scope(:origin => @loc_a).where(["distance < ? and city = ?", 5, 'Coppell'])
    locations = Location.within(5, :origin => @loc_a).where(["city = ?", 'Coppell'])
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_beyond
    locations = Location.beyond(3.95, :origin => @loc_a)
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_find_beyond_with_token
    # locations = Location.find(:all, :beyond => 3.95, :origin => @loc_a)
    #locations = Location.geo_scope(:beyond => 3.95, :origin => @loc_a)
    locations = Location.beyond(3.95, :origin => @loc_a)
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_find_beyond_with_coordinates
    locations = Location.beyond(3.95, :origin =>[@loc_a.lat, @loc_a.lng])
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_find_range_with_token
    locations = Location.in_range(0..10, :origin => @loc_a)
    assert_equal 6, locations.to_a.size
    assert_equal 6, locations.count
  end

  def test_find_range_with_token_with_conditions
    locations = Location.in_range(0..10, :origin => @loc_a).where(["city = ?", 'Coppell'])
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_range_with_token_with_hash_conditions
    locations = Location.in_range(0..10, :origin => @loc_a).where(:city => 'Coppell')
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_range_with_token_excluding_end
    #locations = Location.geo_scope(:range => 0...10, :origin => @loc_a)
    locations = Location.in_range(0...10, :origin => @loc_a)
    assert_equal 6, locations.to_a.size
    assert_equal 6, locations.count
  end

  def test_find_nearest
    assert_equal @loc_a, Location.nearest(:origin => @loc_a).first
  end

  def test_find_nearest_with_coordinates
    assert_equal @loc_a, Location.nearest(:origin =>[@loc_a.lat, @loc_a.lng]).first
  end

  def test_find_nearest_is_scope
    assert Location.nearest(:origin => @loc_a).respond_to? :where
  end

  def test_find_farthest
    assert_equal @loc_e, Location.farthest(:origin => @loc_a).first
  end

  def test_find_farthest_with_coordinates
    assert_equal @loc_e, Location.farthest(:origin =>[@loc_a.lat, @loc_a.lng]).first
  end

  def test_find_farthest_is_scope
    assert Location.farthest(:origin => @loc_a).respond_to? :where
  end

  def test_scoped_distance_column_in_select
    #locations = @starbucks.locations.geo_scope(:origin => @loc_a).order("distance ASC")
    locations = @starbucks.locations.by_distance(:origin => @loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 0, @loc_a.distance_to(locations.first)
    assert_in_delta 3.97, @loc_a.distance_to(locations.last, :units => :miles, :formula => :sphere), 0.01
  end

  def test_scoped_find_with_distance_condition
    #locations = @starbucks.locations.geo_scope(:origin => @loc_a).where("distance < 3.97")
    locations = @starbucks.locations.within(3.97, :origin => @loc_a)
    assert_equal 4, locations.to_a.size
    assert_equal 4, locations.count
  end

  def test_scoped_find_within
    locations = @starbucks.locations.within(3.97, :origin => @loc_a)
    assert_equal 4, locations.to_a.size
    assert_equal 4, locations.count
  end

  def test_scoped_find_with_compound_condition
    locations = @starbucks.locations.within(5, :origin => @loc_a).where("city = 'Coppell'")
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_scoped_find_beyond
    locations = @starbucks.locations.beyond(3.95, :origin => @loc_a)
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_scoped_find_nearest
    assert_equal @loc_a, @starbucks.locations.nearest(:origin => @loc_a).first
  end

  def test_scoped_find_farthest
    assert_equal @loc_e, @starbucks.locations.farthest(:origin => @loc_a).first
  end

  def test_ip_geocoded_distance_column_in_select
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    locations = Location.by_distance(:origin => LOCATION_A_IP)
    assert_equal 6, locations.to_a.size
    assert_equal 0, @loc_a.distance_to(locations.first)
    assert_in_delta 3.97, @loc_a.distance_to(locations.last, :units => :miles, :formula => :sphere), 0.01
  end

  def test_ip_geocoded_find_with_distance_condition
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    locations = Location.within(3.97, :origin => LOCATION_A_IP)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_ip_geocoded_find_within
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    locations = Location.within(3.97, :origin => LOCATION_A_IP)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_ip_geocoded_find_with_compound_condition
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    locations = Location.within(5, :origin => LOCATION_A_IP).where("city = 'Coppell'")
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_ip_geocoded_find_with_secure_compound_condition
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    locations = Location.within(5, :origin => LOCATION_A_IP).where(["city = ?", 'Coppell'])
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_ip_geocoded_find_beyond
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    locations = Location.beyond(3.95, :origin => LOCATION_A_IP)
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_ip_geocoded_find_nearest
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    assert_equal @loc_a, Location.nearest(:origin => LOCATION_A_IP).first
  end

  def test_ip_geocoded_find_farthest
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with(LOCATION_A_IP).returns(@location_a)
    assert_equal @loc_e, Location.farthest(:origin => LOCATION_A_IP).first
  end

  def test_ip_geocoder_exception
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with('127.0.0.1').returns(Geokit::GeoLoc.new)
    assert_raises Geokit::Geocoders::GeocodeError do
      Location.farthest(:origin => '127.0.0.1').first
    end
  end

  def test_address_geocode
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with('Irving, TX').returns(@location_a)
    #locations = Location.geo_scope(:origin => 'Irving, TX').where(["distance < ? and city = ?", 5, 'Coppell'])
    locations = Location.within(5, :origin => 'Irving, TX').where(["city = ?", 'Coppell'])
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_with_custom_distance_condition
    locations = CustomLocation.within(3.97, :origin => @loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_with_custom_distance_condition_using_custom_origin
    #locations = CustomLocation.geo_scope(:origin => @custom_loc_a).where("dist < 3.97")
    locations = CustomLocation.within(3.97, :origin => @custom_loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_within_with_custom
    locations = CustomLocation.within(3.97, :origin => @loc_a)
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_within_with_coordinates_with_custom
    locations = CustomLocation.within(3.97, :origin =>[@loc_a.lat, @loc_a.lng])
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end

  def test_find_with_compound_condition_with_custom
    #locations = CustomLocation.geo_scope(:origin => @loc_a).where("dist < 5 and city = 'Coppell'")
    locations = CustomLocation.within(5, :origin => @loc_a).where("city = 'Coppell'")
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  # REMOVED AS SAME AS BELOW
  #def test_find_with_secure_compound_condition_with_custom
  #  locations = CustomLocation.geo_scope(:origin => @loc_a).where(["dist < ? and city = ?", 5, 'Coppell'])
  #  assert_equal 1, locations.all.size
  #  assert_equal 1, locations.count
  #end

  def test_find_beyond_with_custom
    locations = CustomLocation.beyond(3.95, :origin => @loc_a)
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_find_beyond_with_coordinates_with_custom
    locations = CustomLocation.beyond(3.95, :origin =>[@loc_a.lat, @loc_a.lng])
    assert_equal 1, locations.to_a.size
    assert_equal 1, locations.count
  end

  def test_find_nearest_with_custom
    assert_equal @custom_loc_a, CustomLocation.nearest(:origin => @loc_a).first
  end

  def test_find_nearest_with_coordinates_with_custom
    assert_equal @custom_loc_a, CustomLocation.nearest(:origin =>[@loc_a.lat, @loc_a.lng]).first
  end

  def test_find_farthest_with_custom
    assert_equal @custom_loc_e, CustomLocation.farthest(:origin => @loc_a).first
  end

  def test_find_farthest_with_coordinates_with_custom
    assert_equal @custom_loc_e, CustomLocation.farthest(:origin =>[@loc_a.lat, @loc_a.lng]).first
  end

  def test_find_with_array_origin
    #locations = Location.geo_scope(:origin =>[@loc_a.lat,@loc_a.lng]).where("distance < 3.97")
    locations = Location.within(3.97, :origin =>[@loc_a.lat,@loc_a.lng])
    assert_equal 5, locations.to_a.size
    assert_equal 5, locations.count
  end


  # Bounding box tests

  def test_find_within_bounds
    locations = Location.in_bounds([@sw,@ne])
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_within_bounds_ordered_by_distance
    #locations = Location.in_bounds([@sw,@ne], :origin=>@bounds_center).order('distance asc')
    locations = Location.in_bounds([@sw,@ne]).by_distance(:origin => @bounds_center)
    assert_equal locations[0], locations(:d)
    assert_equal locations[1], locations(:a)
  end

  def test_find_within_bounds_with_token
    #locations = Location.geo_scope(:bounds=>[@sw,@ne])
    locations = Location.in_bounds([@sw,@ne])
    assert_equal 2, locations.to_a.size
    assert_equal 2, locations.count
  end

  def test_find_within_bounds_with_string_conditions
    #locations = Location.geo_scope(:bounds=>[@sw,@ne]).where("id !=#{locations(:a).id}")
    locations = Location.in_bounds([@sw,@ne]).where("id !=#{locations(:a).id}")
    assert_equal 1, locations.to_a.size
  end

  def test_find_within_bounds_with_array_conditions
    #locations = Location.geo_scope(:bounds=>[@sw,@ne]).where(["id != ?", locations(:a).id])
    locations = Location.in_bounds([@sw,@ne]).where(["id != ?", locations(:a).id])
    assert_equal 1, locations.to_a.size
  end

  def test_find_within_bounds_with_hash_conditions
    #locations = Location.geo_scope(:bounds=>[@sw,@ne]).where({:id => locations(:a).id})
    locations = Location.in_bounds([@sw,@ne]).where({:id => locations(:a).id})
    assert_equal 1, locations.to_a.size
  end

  def test_auto_geocode
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("Irving, TX").returns(@location_a)
    store=Store.new(:address=>'Irving, TX')
    store.save
    assert_equal store.lat,@location_a.lat
    assert_equal store.lng,@location_a.lng
    assert_equal 0, store.errors.size
  end

  def test_auto_geocode_failure
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("BOGUS").returns(Geokit::GeoLoc.new)
    store=Store.new(:address=>'BOGUS')
    store.save
    assert store.new_record?
    assert_equal 1, store.errors.size
  end

  # Test :through

  #def test_find_with_through
  #  organizations = MockOrganization.geo_scope(:origin => @location_a).order('distance ASC')
  #  assert_equal 2, organizations.all.size
  #  organizations = MockOrganization.geo_scope(:origin => @location_a).where("distance < 3.97")
  #  assert_equal 1, organizations.count
  #end

  def test_find_with_through_with_hash
    #people = MockPerson.geo_scope(:origin => @location_a).order('distance ASC')
    people = MockPerson.order('distance ASC')
    assert_equal 2, people.size
    assert_equal 2, people.count
  end

  def test_sort_by_distance_from
    locations = Location.all
    unsorted = [locations(:a), locations(:b), locations(:c), locations(:d), locations(:e), locations(:f)]
    sorted   = [locations(:a), locations(:b), locations(:c), locations(:f), locations(:d), locations(:e)]
    assert_equal sorted, locations.sort_by{|l| l.distance_to(locations(:a))}

    unsorted_collection = DistanceCollection.new(unsorted)
    unsorted_collection.set_distance_from(locations(:a))
    assert_equal sorted, unsorted_collection.sort_by(&:distance)
  end

end
