# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)
require 'friendly_id'

# We need to test basic compatibility between FriendlyId (4.x)
# and Globalize because both override ActiveRecord::Base#relation
class FriendlyIdTest < Test::Unit::TestCase
  test 'Globalized model extends FriendlyId' do
    post = SluggedPost.new(:title => 'English title', :slug => 'my-slug')
    post.save!
    assert_equal post, SluggedPost.find('my-slug')
    assert_equal post, SluggedPost.find(1)
  end

  if ::ActiveRecord::VERSION::STRING >= "3.2.1"
    test 'overridden where_values_hash still works' do
      where_values = SluggedPost.with_translations(:en).where(:slugged_post_translations => {:title => 'test_title'}).where_values_hash
      assert_equal 'test_title', where_values[:title]
    end
  end
end
