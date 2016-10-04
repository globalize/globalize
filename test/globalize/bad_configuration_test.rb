# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class BadConfigurationTest < MiniTest::Spec
  describe 'finders on data with bad configuration' do
    it 'works with find_by' do
      bad_configuration = BadConfiguration.create(:name => "foo")
      assert_equal bad_configuration, BadConfiguration.find_by(:name => "foo")
    end
  end

  describe '#columns_hash' do
    it 'returns columns on model table minus translated attributes' do
      assert_equal ["id"], BadConfiguration.columns_hash.keys
    end
  end
end
