# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class TranslatedAttributesQueryTest
  class WhereValuesHashTest < Test::Unit::TestCase
    test 'includes translated attributes' do
      where_values = User.with_translations(:en).where(:email => 'foo@example.com', :user_translations => {:name => 'test_name'}).where_values_hash

      assert_equal 'foo@example.com', where_values[:email]
      assert_equal 'test_name', where_values[:name]
    end
  end
end
