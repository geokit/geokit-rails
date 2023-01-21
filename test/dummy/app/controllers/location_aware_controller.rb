class LocationAwareController < ApplicationController #:nodoc: all
  before_action :set_ip, only: [:index,:cookietest,:sessiontest]
  before_action :set_ip_bad, only: [:failtest]
  before_action :setup, only: [:cookietest,:sessiontest]
  geocode_ip_address

  def index
    render plain: ''
  end

  def cookietest
    cookies[:geo_location] = @success.to_json
    render plain: ''
  end

  def sessiontest
    session[:geo_location] = @success.to_json
    render plain: ''
  end

  def failtest
    render plain: ''
  end

  def rescue_action(e) raise e end;
  private
  def set_ip
    request.remote_ip = "good ip"
  end
  def set_ip_bad
    request.remote_ip = "bad ip"
  end
  def setup
    @success = Geokit::GeoLoc.new
    @success.provider = "hostip"
    @success.lat = 41.7696
    @success.lng = -88.4588
    @success.city = "Sugar Grove"
    @success.state = "IL"
    @success.country_code = "US"
    @success.success = true
  end
end