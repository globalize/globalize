class Category < ActiveRecord::Base
  has_and_belongs_to_many :products
  translates :title
end
