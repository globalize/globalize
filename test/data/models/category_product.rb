class CategoryProduct < ActiveRecord::Base
  belongs_to :category
  belongs_to :product
end
