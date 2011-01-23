require File.expand_path('../../test_helper', __FILE__)

class DynamicFindersTest < Test::Unit::TestCase
  test "respond_to? returns true for dynamic finders" do
    assert Post.respond_to? :find_by_title
    assert Post.respond_to? :find_first_by_title
  end

  test "simple dynamic finders do work" do
    Post.create(:title => 'foo')
    Post.create(:title => 'bar')

    assert_equal 'foo', Post.find_by_title('foo').first.title
    assert_equal 'foo', Post.find_first_by_title('foo').title
  end

  test "simple dynamic finders do work on sti models" do
    Child.create(:content => 'foo')
    Child.create(:content => 'bar')

    assert_equal 'foo', Child.find_by_content('foo').first.content
    assert_equal 'foo', Child.find_first_by_content('foo').content
  end

  test "records returned by dynamic finders have writable attributes" do
    Post.create(:title => 'original')
    post = Post.find_first_by_title('original')
    post.title = 'modified'
    assert_nothing_raised(ActiveRecord::ReadOnlyRecord) do
      post.save
    end
  end
end
