class Product < ActiveRecord::Base
  translates :name
  translates :array_values if Globalize::Test::Database.native_array_support?
  has_many :categories_products
  has_many :categories, through: :categories_products
end
