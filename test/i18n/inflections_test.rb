require File.expand_path('../../test_helper', __FILE__)

class InflectionsPatchTest < Minitest::Spec
  before(:each) do
    I18n.pretend_fallbacks
    @previous_fallbacks = I18n.fallbacks
  end

  after(:each) do
    instances = ActiveSupport::Inflector::Inflections.instance_variable_get(:@__instance__)
    instances.delete(:xx)
    instances.delete(:yy)
    I18n.fallbacks = @previous_fallbacks
    I18n.hide_fallbacks
  end

  it 'keeps the default :en rules when a fallback locale has an empty inflections instance' do
    # Applications create empty inflections for non-English locales on purpose,
    # so that the English rules are not applied to words of other languages.
    ActiveSupport::Inflector.inflections(:xx) { }
    I18n.fallbacks = I18n::Locale::Fallbacks.new(en: :xx)

    assert_equal 'translations', ActiveSupport::Inflector.pluralize('translation', :en)
  end

  it 'falls back to the :en rules for a locale without own inflections' do
    # Broken in vanilla Rails 8.1.0/8.1.1, fixed in 8.1.2 (rails/rails#56344)
    if ActiveSupport.version >= Gem::Version.new('8.1.0') && ActiveSupport.version < Gem::Version.new('8.1.2')
      skip 'Rails-side inflections fallback bug, fixed in Rails 8.1.2'
    end

    I18n.fallbacks = I18n::Locale::Fallbacks.new(:en)

    assert_equal 'translations', ActiveSupport::Inflector.pluralize('translation', :yy)
  end

  it 'keeps working when I18n.fallbacks is not available' do
    begin
      I18n.hide_fallbacks
      assert_equal 'translations', ActiveSupport::Inflector.pluralize('translation', :en)
    ensure
      I18n.pretend_fallbacks
    end
  end
end
