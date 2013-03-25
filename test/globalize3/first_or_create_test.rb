# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class FirstOrCreateTest < Test::Unit::TestCase
  def test_first_or_create_with_translations_and_when_row_exists
    post = Post.create(:title => 'test_title')

    assert_equal Post.with_translations(:en).where(post_translations: {title: 'test_title'}).first_or_create, post
  end

  def test_first_or_create_with_translations_and_when_row_does_not_exist
    post = Post.with_translations(:en).where(post_translations: {title: 'test_title'}).first_or_create

    assert_equal 'test_title', post.title
  end
end 
