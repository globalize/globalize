require File.expand_path('../../test_helper', __FILE__)

class CompositeForeignKeyTest < Minitest::Spec
  def require_composite_foreign_keys
    skip 'composite foreign keys need Rails 7.2' unless Globalize.rails_7_2?
  end

  def define_model(&block)
    Class.new(ActiveRecord::Base) do
      self.table_name = 'store_categories'

      def self.name
        'StoreCategory'
      end

      class_eval(&block)
    end
  end

  it 'writes every foreign key column' do
    require_composite_foreign_keys

    category = StoreCategory.create!(store_id: 7, name: 'Shoes')

    assert_equal [[7, category.id, 'en', 'Shoes']],
      StoreCategory::Translation.pluck(:store_id, :store_category_id, :locale, :name)
  end

  it 'reads translations through every foreign key column' do
    require_composite_foreign_keys

    category = StoreCategory.create!(store_id: 7, name: 'Shoes')
    StoreCategory::Translation.create!(store_id: 8, store_category_id: category.id, locale: 'de', name: 'Andere')

    assert_equal 'Shoes', StoreCategory.find_by(id: category.id).name
    assert_equal ['Shoes'], StoreCategory.includes(:translations).map(&:name)
    assert_equal ['Shoes'], StoreCategory.with_translations('en').map(&:name)
    assert_equal [:en], category.reload.translations.map(&:locale)
  end

  it 'writes translations in another locale' do
    require_composite_foreign_keys

    category = StoreCategory.create!(store_id: 7, name: 'Shoes')
    Globalize.with_locale(:de) { category.update!(name: 'Schuhe') }

    assert_equal [['en', 'Shoes', 7], ['de', 'Schuhe', 7]],
      StoreCategory::Translation.order(:id).pluck(:locale, :name, :store_id)
  end

  it 'validates uniqueness within a scope, ignoring the record itself' do
    require_composite_foreign_keys

    category = StoreCategory.create!(store_id: 7, name: 'Shoes')

    assert category.valid?
    refute StoreCategory.new(store_id: 7, name: 'Shoes').valid?
    assert StoreCategory.new(store_id: 8, name: 'Shoes').valid?
  end

  it 'validates uniqueness against the saved foreign key when it changes' do
    require_composite_foreign_keys

    category = UnscopedStoreCategory.create!(store_id: 7, name: 'Shoes')
    category.store_id = 8

    assert category.valid?
  end

  it 'destroys the translations with the record' do
    require_composite_foreign_keys

    StoreCategory.create!(store_id: 7, name: 'Shoes').destroy!

    assert_equal 0, StoreCategory::Translation.count
  end

  it 'needs a foreign key column for each query constraint' do
    require_composite_foreign_keys

    error = assert_raises(ArgumentError) do
      define_model do
        query_constraints :store_id, :id
        translates :name
      end
    end

    assert_includes error.message, 'foreign_key: [:store_id, :store_category_id]'
  end

  it 'checks the foreign key when query constraints are declared after translates' do
    skip 'query_constraints needs Rails 7.1' unless Globalize.rails_7_1?

    assert_raises(ArgumentError) do
      define_model do
        translates :name
        query_constraints :store_id, :id
      end
    end
  end

  it 'needs as many foreign key columns as query constraints' do
    require_composite_foreign_keys

    assert_raises(ArgumentError) do
      define_model do
        query_constraints :store_id, :id
        translates :name, foreign_key: [:store_category_id]
      end
    end
  end

  it 'needs query constraints for a composite foreign key' do
    require_composite_foreign_keys

    error = assert_raises(ArgumentError) { MismatchedStoreCategory.create!(store_id: 7, name: 'Shoes') }
    assert_includes error.message, 'needs query constraints with a column for each of its translations\' foreign key columns (store_id, store_category_id)'
  end

  it 'needs Rails 7.2 for a composite foreign key' do
    skip 'Rails 7.2 supports composite foreign keys' if Globalize.rails_7_2?

    error = assert_raises(ArgumentError) do
      define_model do
        translates :name, foreign_key: [:store_id, :store_category_id]
      end
    end

    assert_includes error.message, 'Rails 7.2'
  end

  it 'needs Rails 7.2 for query constraints' do
    skip 'query_constraints needs Rails 7.1' unless Globalize.rails_7_1?
    skip 'Rails 7.2 supports composite foreign keys' if Globalize.rails_7_2?

    error = assert_raises(ArgumentError) do
      define_model do
        query_constraints :store_id, :id
        translates :name
      end
    end

    assert_includes error.message, 'StoreCategory has query constraints (store_id, id), so its translations need a composite foreign key, which needs Rails 7.2 or later.'
  end
end
