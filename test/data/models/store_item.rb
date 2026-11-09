if Globalize.rails_7_1?
  class StoreItem < ActiveRecord::Base
    self.primary_key = [:store_id, :id]
    translates :name
    validates :name, uniqueness: true
  end
end
