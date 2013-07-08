# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class OrderTest < Test::Unit::TestCase
  test "using symbol in order clause with pg on trasnlated model when using dynamic finder causes an error" do
    Post.order(:created_at).find_by_title('title')
  end

  test "it works when using where" do
    Post.order(:created_at).where('title')
  end

  test "works on a non translated model" do
    MyPost.order(:created_at).find_by_title('title')
  end
end

