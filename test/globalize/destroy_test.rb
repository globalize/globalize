# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class DestroyTest < Minitest::Spec
  describe '.destroy_all' do
    before do
      @posts = [Post.create(:title => 'title'), Post.create(:title => 'title')]
      Globalize.with_locale(:ja) do
        @posts[0].update(:title => 'タイトル1')
        @posts[1].update(:title => 'タイトル2')
      end
    end

    describe 'with conditions including translated attributes' do
      it 'destroys translations' do
        Post.where(:title => 'title').destroy_all
        assert_equal 0, Post::Translation.count
      end
    end

    describe 'called on a relation with translated attributes' do
      it 'destroys translations' do
        Post.where(:title => 'title').destroy_all
        assert_equal 0, Post::Translation.count
      end
    end
  end
end
