require 'paper_trail'

class Dish < ActiveRecord::Base
  belongs_to :restaurant
  
  translates :name
  
  has_paper_trail
end