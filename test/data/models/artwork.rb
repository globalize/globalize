class Artwork < ActiveRecord::Base
  translates :title, :subtitle
  accepts_nested_attributes_for :translations
end
