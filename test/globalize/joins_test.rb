# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class JoinsTest < Minitest::Spec

  describe 'pluck on translations table' do

    it "returns translated attribute" do
      Post.create(title: "my title")

      assert_equal ["my title"], Post.includes(:translations).pluck("post_translations.title")
    end
  end
end
