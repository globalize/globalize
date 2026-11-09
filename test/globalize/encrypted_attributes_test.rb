require File.expand_path('../../test_helper', __FILE__)

class EncryptedAttributesTest < Minitest::Spec
  WARNING = /`encrypts :title` on EncryptedPost doesn't encrypt its translations, which are stored in post_translations/

  def define_model(&block)
    Class.new(ActiveRecord::Base) do
      self.table_name = 'posts'

      def self.name
        'EncryptedPost'
      end

      class_eval(&block)
    end
  end

  it 'warns when a translated attribute is encrypted before translates' do
    assert_output(nil, WARNING) do
      define_model do
        encrypts :title
        translates :title
      end
    end
  end

  it 'warns when a translated attribute is encrypted after translates' do
    assert_output(nil, WARNING) do
      define_model do
        translates :title
        encrypts :title
      end
    end
  end

  it 'does not warn when the translation class encrypts the attribute' do
    assert_output(nil, '') do
      define_model do
        translates :title
        translation_class.encrypts :title
      end
    end
  end

  it 'does not warn for untranslated encrypted attributes' do
    assert_output(nil, '') do
      define_model do
        encrypts :content
        translates :title
        encrypts :published
      end
    end
  end
end
