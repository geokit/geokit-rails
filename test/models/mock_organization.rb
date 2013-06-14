require 'models/mock_address'

class MockOrganization < ActiveRecord::Base
  has_one :mock_address, :as => :addressable
  acts_as_mappable :through => :mock_address
end