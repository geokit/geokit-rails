class Company < ActiveRecord::Base
  has_many :locations
end