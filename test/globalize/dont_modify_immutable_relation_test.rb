# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class DontModifyImmutableRelationTest < MiniTest::Spec
  describe 'going through has_many :through relation and where.not condition' do
    it "does not raises ActiveRecord::ImmutableRelation" do
      # This should not raise ActiveRecord::ImmutableRelation
      Author.new.comments_without_translations.where.not(content: 'anything really')
    end
  end
end
