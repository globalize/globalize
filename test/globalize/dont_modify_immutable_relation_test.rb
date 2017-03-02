# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class DontModifyImmutableRelationTest < MiniTest::Spec
  describe 'going through has_many :through relation and where.not condition' do
    it "does not raises ActiveRecord::ImmutableRelation" do
      expect {
        Author.new.comments_without_translations
              .where.not(content: 'anything really')
      }.not_to raise_exception(::ActiveRecord::ImmutableRelation)
    end
  end
end
