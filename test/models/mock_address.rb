class MockAddress < ActiveRecord::Base
  belongs_to :addressable, :polymorphic => true
  acts_as_mappable
end