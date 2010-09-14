class CustomLocation < ActiveRecord::Base
  belongs_to :company
  acts_as_mappable :distance_column_name => 'dist', 
                   :default_units => :kms, 
                   :default_formula => :flat, 
                   :lat_column_name => 'latitude', 
                   :lng_column_name => 'longitude'
                   
  def to_s
    "lat: #{latitude} lng: #{longitude} dist: #{dist}"
  end
end