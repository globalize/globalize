# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class OrderTest < MiniTest::Spec
  describe 'order with fallbacks' do
    before(:each) do
      @previous_backend = I18n.backend
      I18n.pretend_fallbacks
      I18n.backend = BackendWithFallbacks.new

      I18n.locale = :en
      I18n.fallbacks = ::I18n::Locale::Fallbacks.new
      I18n.fallbacks.map('en' => [ 'it' ])

      @first_product = with_locale(:en) { Product.create(:name => 'first') }
      @second_product = with_locale(:it) { Product.create(:name => 'secondo') }
    end

    after(:each) do
      I18n.fallbacks.clear
      I18n.hide_fallbacks
      I18n.backend = @previous_backend
    end

    it "should sort ascendand with a Symbol translated column" do
      assert_equal %w(first secondo), Product.order(:name).map(&:name)
    end

    it "should sort ascendand with a Symbol translated column with a preset selection" do
      assert_equal %w(first secondo), Product.select(:id).order(:name).map(&:name)
    end

    it "should sort ascendand with a Hash translated column" do
      assert_equal %w(first secondo), Product.order({:name => :asc}).map(&:name)
    end

    it "should sort descendand with a Hash translated column" do
      assert_equal %w(secondo first), Product.order({:name => :desc}).map(&:name)
    end

    it "should sort ascendand with a Hash translated column with a preset selection" do
      assert_equal %w(first secondo), Product.select(:id).order({:name => :asc}).map(&:name)
    end

    it "should sort descendand with a Hash translated column with a preset selection" do
      assert_equal %w(secondo first), Product.select(:id).order({:name => :desc}).map(&:name)
    end

    it "should not return products with ID from translations table" do
      with_locale(:fr) { @first_product.update_attributes(name: 'premier') }
      premier_product = with_locale(:fr) { Product.order(name: :asc).first }
      assert_equal @first_product.name, premier_product.name, 'products should be the same record as shown by their default name'
      assert_equal @first_product, premier_product, 'returned product records should have the same ID from the products table'
    end
  end
end
