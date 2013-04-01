Dir[File.expand_path('../models/**/*.rb', __FILE__)].each do |model|
  require model
end

class Product < ActiveRecord::Base
  attr_accessible :name
  translates :description
  accepts_nested_attributes_for :translations
end
