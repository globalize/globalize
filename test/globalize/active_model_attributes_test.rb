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

  describe "type casting in queries" do
    it "casts query values using the custom attribute type" do
      TypedPost.create!(title: "hello")
      assert_equal 1, TypedPost.where(title: "  hello  ").count
    end
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
