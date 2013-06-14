require 'models/mock_family'
require 'models/mock_house'

class MockPerson < ActiveRecord::Base
  belongs_to :mock_family
  acts_as_mappable :through => { :mock_family => :mock_house }
end