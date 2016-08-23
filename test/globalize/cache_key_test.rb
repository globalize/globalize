# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)
require 'active_support/testing/time_helpers'

class CacheKeyTest < MiniTest::Spec
  include ActiveSupport::Testing::TimeHelpers

  describe '#cache_key' do
    it "changes when the translation is updated" do
      travel_to(1.day.ago)
      product = with_locale(:en) { Product.create(:name => 'first') }
      original_cache_key = product.cache_key

      travel_back
      product_translation = product.translation_for(:en)
      product_translation.name = "second"
      product_translation.save!

      refute_equal original_cache_key, product.cache_key
    end

    it "works even for an uninitialized locale" do
      product = with_locale(:en) { Product.create(:name => 'first') }

      refute_nil with_locale(:de) { product.cache_key }
    end
  end
end
