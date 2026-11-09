require File.expand_path('../../test_helper', __FILE__)

class CompositePrimaryKeyTest < Minitest::Spec
  it 'writes the foreign key of a model with a composite primary key' do
    skip 'composite primary keys need Rails 7.1' unless Globalize.rails_7_1?

    StoreItem.create!(id: [7, 3], name: 'Boots')

    assert_equal [[3, 'Boots']], StoreItem::Translation.pluck(:store_item_id, :name)
    assert_equal 'Boots', StoreItem.find([7, 3]).name
  end

  it 'validates uniqueness against records whose key shares a value with this one' do
    skip 'composite primary keys need Rails 7.1' unless Globalize.rails_7_1?

    item = StoreItem.create!(id: [7, 3], name: 'Shoes')
    StoreItem.create!(id: [1, 7], name: 'Boots')

    assert item.valid?
    item.name = 'Boots'
    refute item.valid?
  end
end
