require 'models/mock_house'

class MockFamily < ActiveRecord::Base
  belongs_to :mock_house
end