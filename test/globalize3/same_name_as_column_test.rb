# encoding: utf-8
require File.expand_path('../../test_helper', __FILE__)

class SameNameAsColumnTest < Test::Unit::TestCase
  test "translation should access value" do
    value = 'Actual content'
    model = SameNameAsColumn.new
    model.same_name_as_column = value
    assert model.save
    assert_equal SameNameAsColumn.last.same_name_as_column, value
  end
end
