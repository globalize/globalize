# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class OrderTest < MiniTest::Spec
  before(:each) do
    @previous_backend = I18n.backend
    I18n.pretend_fallbacks
    I18n.backend = BackendWithFallbacks.new

    I18n.locale = :en
    I18n.fallbacks = ::I18n::Locale::Fallbacks.new
    I18n.fallbacks.map('en' => [ 'it' ])
  end

  after(:each) do
    I18n.fallbacks.clear
    I18n.hide_fallbacks
    I18n.backend = @previous_backend
  end

  describe 'order' do
    it "should be able to sort by a translated attribute with fallbacks" do
      product = with_locale(:en) { Product.create(:name => 'first') }
      product = with_locale(:it) { Product.create(:name => 'primo') }
      assert_equal %w(first primo), Product.order(:name).map(&:name)
    end
  end
end
