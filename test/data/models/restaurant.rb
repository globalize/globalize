class Restaurant < ActiveRecord::Base
  has_many :dishes
  
  accepts_nested_attributes_for :dishes
end