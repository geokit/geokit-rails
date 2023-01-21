require 'test_helper'

class IpGeocodeLookupTest < ActionDispatch::IntegrationTest#ActiveSupport::TestCase#ActionController::TestCase
  # tests LocationAwareController
  
  def setup
    # @controller = LocationAwareController
    @success = Geokit::GeoLoc.new
    @success.provider = "hostip"
    @success.lat = 41.7696
    @success.lng = -88.4588
    @success.city = "Sugar Grove"
    @success.state = "IL"
    @success.country_code = "US"
    @success.success = true
    
    @failure = Geokit::GeoLoc.new
    @failure.provider = "hostip"
    @failure.city = "(Private Address)"
    @failure.success = false
  end

  def test_no_location_in_cookie_or_session
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("good ip").returns(@success)
    get '/'
    assert_response :success
    assert_equal @success, @request.session[:geo_location]
    assert_not_nil cookies[:geo_location]
    assert_equal @success.to_json, cookies[:geo_location]
  end
  
  def test_location_in_cookie
    get '/cookietest'
    assert_not_nil cookies[:geo_location]
    assert_equal @success.to_json, cookies[:geo_location]
  end

  def test_location_in_session
    get '/sessiontest'
    assert_response :success
    assert_equal @success, Geokit::GeoLoc.new(JSON.parse(session[:geo_location]).transform_keys(&:to_sym))
  end

  def test_ip_not_located
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("bad ip").returns(@failure)
    get '/failtest'
    assert_nil @request.session[:geo_location]
  end
end