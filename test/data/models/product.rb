class Product < ActiveRecord::Base
  translates :name, :array_values
end
