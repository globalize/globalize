require 'friendly_id'

class SluggedPost < ActiveRecord::Base
  translates :title
  extend FriendlyId
  friendly_id :slug
end
