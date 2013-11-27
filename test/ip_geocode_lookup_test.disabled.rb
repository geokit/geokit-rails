require 'test_helper'

module TestApp
  class Application < Rails::Application
  end
end

TestApp::Application.routes.draw do
  match ':controller(/:action(/:id(.:format)))'
end

class LocationAwareController < ActionController::Base #:nodoc: all
  geocode_ip_address
  
  def index
    render :nothing => true
  end
  
  def rescue_action(e) raise e end; 
end

class ActionController::TestRequest #:nodoc: all
  attr_accessor :remote_ip
end

class IpGeocodeLookupTest < ActionController::TestCase
  tests LocationAwareController
  
  def setup
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
    @request.remote_ip = "good ip"
    get :index
    verify
  end
  
  def test_location_in_cookie
    @request.remote_ip = "good ip"
    @request.cookies['geo_location'] = @success.to_yaml
    get :index
    verify
  end
  
  def test_location_in_session
    @request.remote_ip = "good ip"
    @request.session[:geo_location] = @success
    @request.cookies['geo_location'] = CGI::Cookie.new('geo_location', @success.to_yaml)
    get :index
    verify
  end
  
  def test_ip_not_located
    Geokit::Geocoders::MultiGeocoder.expects(:geocode).with("bad ip").returns(@failure)
    @request.remote_ip = "bad ip"
    get :index
    assert_nil @request.session[:geo_location]
  end
  
  private
  
  def verify
    assert_response :success    
    assert_equal @success, @request.session[:geo_location]
    assert_not_nil cookies['geo_location']
    assert_equal @success, YAML.load(cookies['geo_location'])
  end
end