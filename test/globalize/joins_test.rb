# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class JoinsTest < MiniTest::Spec

  describe 'pluck on translations table' do

    it "returns translated attribute" do
      Post.create(title: "title")
      assert_equal Post.includes(:translations).pluck(:title), ["title"]
    end
  end
end
