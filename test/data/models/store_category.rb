if Globalize.rails_7_2?
  class StoreCategory < ActiveRecord::Base
    query_constraints :store_id, :id
    translates :name, foreign_key: [:store_id, :store_category_id]
    validates :name, uniqueness: { scope: :store_id }
  end

  class UnscopedStoreCategory < ActiveRecord::Base
    self.table_name = 'store_categories'
    query_constraints :store_id, :id
    translates :name, foreign_key: [:store_id, :store_category_id], table_name: 'store_category_translations'
    validates :name, uniqueness: true
  end

  class MismatchedStoreCategory < ActiveRecord::Base
    self.table_name = 'store_categories'
    translates :name, foreign_key: [:store_id, :store_category_id], table_name: 'store_category_translations'
  end
end
