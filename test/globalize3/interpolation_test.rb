# encoding: utf-8

require File.expand_path('../../test_helper', __FILE__)

class InterpolationTest < Test::Unit::TestCase
  test "interpolation" do
    user = User.new(:name => 'John %{surname}')
    assert_equal user.name(:surname => 'Bates'), 'John Bates'
  end

  test "interpolation error" do
    user = User.new(:name => 'John %{surname}')
    exception = assert_raise(I18n::MissingInterpolationArgument) { user.name }
    assert_match(/missing interpolation argument.*John %{surname}/, exception.message)
  end
end
