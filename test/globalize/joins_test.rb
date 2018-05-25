# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class JoinsTest < MiniTest::Spec

  describe 'pluck on translations table' do

    it "returns translated attribute" do
      Post.create(title: "my title")

      if Globalize.rails_5?
        assert_equal ["my title"], Post.includes(:translations).pluck("post_translations.title")
      else
        assert_equal ["my title"], Post.includes(:translations).pluck(:title)
      end
    end
  end
end
