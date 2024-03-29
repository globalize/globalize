# encoding: utf-8

require File.expand_path('../test_helper', __FILE__)

class GlobalizeTest < Minitest::Spec

  describe 'translated record' do

    it "has many translations" do
      assert_has_many(Post, :translations)
    end

    describe 'new record' do
      it "has no translations when first instantiated" do
        assert_equal [], Post.new.translations
      end
    end

    describe 'created record' do
      it "saves attribute in given local if locale passed in" do
        post = Post.create(:title => 'Titel', :locale => :de)
        assert_translated post, :de, :title, 'Titel'
      end

      it "can translate boolean values" do
        post = Post.create(:title => 'Titel', :published => true, :locale => :de)
        assert_translated post, :de, :published, true
      end

      it "can translate datetime values" do
        now = Time.now
        post = Post.create(:title => 'Titel', :published_at => now, :locale => :de)
        assert_translated post, :de, :published_at, now
      end
    end

    describe '#attributes=' do
      it "uses given locale if locale passed in" do
        post = Post.create(:title => 'title')
        post.attributes = { :title => 'Titel', :locale => :de }
        post.save
        post.reload

        assert_equal 2, post.translations.size
        assert_translated post, :de, :title, 'Titel'
        assert_translated post, :en, :title, 'title'
      end

      it "bug with same translations" do
        post = Post.create(:title => 'Titel')
        post.attributes = { :title => 'Titel', :locale => :de }
        post.attributes = { :title => 'title', :locale => :en }
        post.save
        post.reload

        assert_equal 2, post.translations.size
        assert_translated post, :de, :title, 'Titel'
        assert_translated post, :en, :title, 'title'

        post.attributes = { :title => 'title', :locale => :de }
        post.attributes = { :title => 'Titel', :locale => :en }
        post.save
        post.reload

        assert_equal 2, post.translations.size
        assert_translated post, :de, :title, 'title'
        assert_translated post, :en, :title, 'Titel'
      end
    end

    describe 'associations' do
      it "create on associations works" do
        blog = Blog.create
        blog.posts.create(:title => 'title')
        blog.posts.create(:title => 'Titel', :locale => :de)

        assert_equal 2, blog.posts.size
        assert_translated blog.posts.first, :en, :title, 'title'
        assert_translated blog.posts.last,  :de, :title, 'Titel'
      end

      it "works with named scopes" do
        post = Blog.create.posts.create(:title => 'some title')
        post.reload

        assert_translated post, :en, :title, 'some title'
      end
    end

    describe '#update' do
      it "saves translations record for locale passed in" do
        post = Post.create(:title => 'Titel', :locale => :de)
        post.update(:title => 'title', :locale => :en)

        assert_equal 2, post.translations.size
        assert_translated post, :de, :title, 'Titel'
        assert_translated post, :en, :title, 'title'
      end

      it "saves translations record for current I18n locale if none is passed in" do
        post = with_locale(:de) { Post.create(:title => 'Titel') }
        with_locale(:en) { post.update(:title => 'title') }

        assert_equal 2, post.translations.size
        assert_translated post, :en, :title, 'title'
        assert_translated post, :de, :title, 'Titel'
      end

      it "does not add tralations if no words changed" do
        product = with_locale(:en) { Product.create(:name => 'name') }
        with_locale(:de) { product.update(:updated_at => Time.now) }

        assert_equal 1, product.reload.translations.size
      end
    end

    describe '#write_attribute' do
      it "saves translations record for locale passed in" do
        post = Post.create(:title => 'title', :locale => :de)
        post.update(:title => 'title', :locale => :en)

        post.reload

        post.write_attribute :title, 'Titel', :locale => :de
        post.write_attribute :title, 'title', :locale => :en
        assert_equal true, post.changed.include?('title')
      end
    end

    describe '#reload' do
      it "works with translated attributes" do
        post = Post.create(:title => 'foo')
        post.title = 'baz'
        post.reload
        assert_equal 'foo', post.title
      end

      it "works with translated attributes when updated elsewhere" do
        post = Post.create(:title => 'foo')
        post.title  # make sure its fetched from the DB

        Post.find_by_id(post.id).update! :title => 'bar'

        post.reload

        assert_equal 'bar', post.title
      end

      it "accepts standard finder options" do
        post = Post.create(:title => "title")
        assert post.reload(:readonly => true, :lock => true)
      end
    end

    describe '#destroy' do
      it "destroy destroys dependent translations" do
        post = Post.create(:title => "title")
        post.update(:title => 'Titel', :locale => :de)
        assert_equal 2, PostTranslation.count
        post.destroy
        assert_equal 0, PostTranslation.count
      end
    end

    if defined?(ActiveRecord::XmlSerializer)
      describe '#to_xml' do
        it "includes translated fields" do
          post = Post.create(:title => "foo", :content => "bar")
          post.reload
          assert post.to_xml =~ %r(<title>foo</title>)
          assert post.to_xml =~ %r(<content>bar</content>)
        end

        it "doesn't affect untranslated models" do
          blog = Blog.create(:description => "my blog")
          blog.reload
          assert blog.to_xml =~ %r(<description>my blog</description>)
        end
      end
    end

    describe '#translated_locales' do
      it "returns locales that have translations" do
        first = Post.create!(:title => 'title', :locale => :en)
        first.update(:title => 'Title', :locale => :de)

        second = Post.create!(:title => 'title', :locale => :en)
        second.update(:title => 'titre', :locale => :fr)

        assert_equal [:de, :en, :fr], Post.translated_locales
        assert_equal [:de, :en], first.translated_locales
        assert_equal [:en, :fr], second.translated_locales

        first.reload
        second.reload

        assert_equal [:de, :en], first.translated_locales
        assert_equal [:en, :fr], second.translated_locales
      end
    end

    describe 'with reload in after_save callback' do
      it "saves correctly" do
        reloading_post = ReloadingPost.create!(:title => 'title')
        assert_equal 'title', reloading_post.title
        assert_translated reloading_post, :en, :title, 'title'
      end
    end

    describe 'subclass of untranslated model' do
      it "works with translated attributes" do
        post = Post.create(:title => 'title')
        translated_comment = TranslatedComment.create(:post => post, :content => 'content')

        translated_comment.translations
        assert_translated translated_comment, :en, :content, 'content'
      end

      it "allows updating of translated attributes" do
        post = Post.create(:title => 'title')
        translated_comment = TranslatedComment.create(:post => post, :content => 'content')

        assert translated_comment.update(:content => 'Inhalt', :locale => :de)
        assert_translated translated_comment, :en, :content, 'content'
        assert_translated translated_comment, :de, :content, 'Inhalt'
      end
    end
  end

  describe 'translated model' do
    describe '.with_translations' do
      it "eager loads translations" do
        Post.create(:title => 'title 1')
        Post.create(:title => 'title 2')

        assert Post.with_translations.first.translations.loaded?
        assert_equal ['title 1', 'title 2'], Post.with_translations.map(&:title).sort
      end
    end

    describe '.translates' do
      describe 'when called a second time' do
        it "adds the new attributes to the translated attributes" do
          page = Page.new :title => 'Wilkommen', :body => 'Ein body', :locale => :de
          assert_translated page, :de, :title, 'Wilkommen'
          assert_translated page, :de, :body, 'Ein body'
        end

        it 'does not extract options from attr_names a second time' do
          # should not raise
          NewsItem.instance_eval %{ translates :title, :foreign_key => :news_id }
        end
      end

      describe ':table_name option' do
        it "uses custom table name" do
          m = ModelWithCustomTableName.create(:name => 'Name', :locale => :en)
          assert_translated m, :en, :name, 'Name'
        end
      end
    end
  end

  describe '#with_locale' do
    def perform_with_locale(locale)
      Thread.new do
        Globalize.with_locale(locale) do
          Thread.pass
          assert_equal locale, Globalize.locale
        end
      end
    end

    it 'sets locale in a single thread' do
      perform_with_locale(:end).join
    end

    it 'sets independent locales in multiple threads' do
      threads = []
      threads << perform_with_locale(:en)
      threads << perform_with_locale(:fr)
      threads << perform_with_locale(:de)
      threads << perform_with_locale(:cz)
      threads << perform_with_locale(:pl)

      threads.each(&:join)
    end
  end
end
