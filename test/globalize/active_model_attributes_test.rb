require File.expand_path('../../test_helper', __FILE__)

class ActiveModelAttributesTest < Minitest::Spec
  describe "attribute type preservation" do
    it "preserves custom attribute type on the model" do
      type = TypedPost.type_for_attribute("title")
      assert_instance_of StrippedStringType, type
    end

    it "propagates custom attribute type to the translation class" do
      type = TypedPost.translation_class.type_for_attribute("title")
      assert_instance_of StrippedStringType, type
    end
  end

  describe "type casting on write" do
    it "casts value using custom attribute type when writing" do
      post = TypedPost.new
      post.title = "  hello  "
      assert_equal "hello", post.title
    end

    it "casts value when using write_attribute" do
      post = TypedPost.new
      post.write_attribute(:title, "  hello  ")
      assert_equal "hello", post.title
    end

    it "casts value using custom attribute type when using multiple translation setter" do
      post = TypedPost.new
      post.title_translations = {:en => " hello ", :fr => " bonjour " }
      assert_translated post, :en, :title, 'hello'
      assert_translated post, :fr, :title, 'bonjour'
    end
  end

  describe "type casting on save" do
    it "persists the cast value in the translation record" do
      post = TypedPost.create!(title: "  hello  ")
      translation = post.translations.first
      assert_equal "hello", translation.title
    end

    it "reads back the cast value after reload" do
      post = TypedPost.create!(title: "  hello  ")
      post.reload
      assert_equal "hello", post.title
    end

    it "persists the casted values using custom attribute type when using multiple translation setter" do
      post = TypedPost.new
      post.title_translations = {:en => " hello ", :fr => " bonjour " }
      post.save!
      post.reload

      assert_translated post, :en, :title, 'hello'
      assert_translated post, :fr, :title, 'bonjour'
    end
  end

  [TypedPost, ReverseTypedPost].each do |model|
    describe "#{model.name} with symbol and serializing types" do
      it "reads persisted values with the declared type" do
        post = model.create!(rating: "3", code: "secret")
        post = model.find(post.id)

        assert_equal 3, post.rating
        assert_equal "secret", post.code
        stored = model.connection.select_value("SELECT code FROM typed_post_translations WHERE id = #{post.translations.first.id}")
        assert_equal "terces", stored
      end

      it "casts each locale" do
        post = model.create!(title: " hello ")
        I18n.with_locale(:de) { post.update!(title: " hallo ") }
        post.reload

        assert_equal "hello", post.title
        assert_equal "hallo", post.title(:de)
      end
    end

    describe "#{model.name} queries" do
      it "serializes query values with the declared type" do
        post = model.create!(code: "secret")

        assert_equal [post], model.where(code: "secret").to_a
        assert_equal [post], model.where.not(code: "other").to_a
      end

      it "finds records with arrays and ranges" do
        matching = model.create!(title: "a", rating: 2)
        model.create!(title: "c", rating: 5)

        assert_equal [matching], model.where(title: %w[a b]).to_a
        assert_equal [matching], model.where(rating: 1..3).to_a
      end
    end
  end

  it "keeps the column type for translated attributes without a declared type" do
    assert_kind_of ActiveModel::Type::Boolean, Post.translation_class.type_for_attribute(:published)
    assert_equal true, Post.create!(title: "title", published: "1").reload.published
  end

  describe "when translates is called before attribute" do
    it "propagates custom attribute type to the translation class" do
      type = ReverseTypedPost.translation_class.type_for_attribute("title")
      assert_instance_of StrippedStringType, type
    end

    it "casts value using custom attribute type when writing" do
      post = ReverseTypedPost.new
      post.title = "  hello  "
      assert_equal "hello", post.title
    end

    it "persists the cast value in the translation record" do
      post = ReverseTypedPost.create!(title: "  hello  ")
      translation = post.translations.first
      assert_equal "hello", translation.title
    end

    it "reads back the cast value after reload" do
      post = ReverseTypedPost.create!(title: "  hello  ")
      post.reload
      assert_equal "hello", post.title
    end
  end
end
