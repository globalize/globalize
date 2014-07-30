require File.expand_path('../../test_helper', __FILE__)

class CacheKeyTest < MiniTest::Spec
  describe '#cache_key' do
    it 'suffixes locale to the cache key' do
      puts 'got into my test'
      post = Post.create(:title => 'Title', :locale => :en)
      post.update_attributes(:title => 'Titel', :locale => :de)

      Globalize.locale = :en
      assert_match /-en$/, post.cache_key
      Globalize.locale = :de
      assert_match /-de$/, post.cache_key
    end
  end
end
