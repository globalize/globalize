class Product < ActiveRecord::Base
  if ::ActiveRecord::VERSION::STRING < "5.0.0"
    translates :name, :array_values
  else
    translates :name
  end
end
