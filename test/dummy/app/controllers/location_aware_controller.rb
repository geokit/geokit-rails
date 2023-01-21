class LocationAwareController < ApplicationController #:nodoc: all
  geocode_ip_address

  def index
    render :nothing => true
  end

  def rescue_action(e) raise e end;
end