class Product < ActiveRecord::Base
  translates :name
  translates :array_values if Globalize::Test::Database.native_array_support?
end
