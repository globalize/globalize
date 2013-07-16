require File.expand_path('../../test_helper', __FILE__)

class ValidationsTest < MiniTest::Spec
  def teardown
    super
    Validatee.reset_callbacks(:validate)
  end

  # TODO
  #
  # it "a record with valid values on non-default locale validates" do
  #   assert Post.create(:title => 'foo', :locale => :de).valid?
  # end

  it "update_attributes succeeds with valid values" do
    post = Post.create(:title => 'foo')
    post.update_attributes(:title => 'baz')
    assert post.valid?
    assert_equal 'baz', Post.first.title
  end

  it "update_attributes fails with invalid values" do
    post = Post.create(:title => 'foo')
    assert !post.update_attributes(:title => '')
    assert !post.valid?
    assert !post.reload.attributes['title'].nil?
    assert_equal 'foo', post.title
  end

  it "validates_presence_of" do
    Validatee.class_eval { validates_presence_of :string }
    assert !Validatee.new.valid?
    assert Validatee.new(:string => 'foo').valid?
  end

  it "validates_confirmation_of" do
    Validatee.class_eval { validates_confirmation_of :string }
    assert !Validatee.new(:string => 'foo', :string_confirmation => 'bar').valid?
    assert Validatee.new(:string => 'foo', :string_confirmation => 'foo').valid?
  end

  it "validates_acceptance_of" do
    Validatee.class_eval { validates_acceptance_of :string, :accept => '1' }
    assert !Validatee.new(:string => '0').valid?
    assert Validatee.new(:string => '1').valid?
  end

  it "validates_length_of (:is)" do
    Validatee.class_eval { validates_length_of :string, :is => 1 }
    assert !Validatee.new(:string => 'aa').valid?
    assert Validatee.new(:string => 'a').valid?
  end

  it "validates_format_of" do
    Validatee.class_eval { validates_format_of :string, :with => /\A\d+\z/ }
    assert !Validatee.new(:string => 'a').valid?
    assert Validatee.new(:string => '1').valid?
  end

  it "validates_inclusion_of" do
    Validatee.class_eval { validates_inclusion_of :string, :in => %w(a) }
    assert !Validatee.new(:string => 'b').valid?
    assert Validatee.new(:string => 'a').valid?
  end

  it "validates_exclusion_of" do
    Validatee.class_eval { validates_exclusion_of :string, :in => %w(b) }
    assert !Validatee.new(:string => 'b').valid?
    assert Validatee.new(:string => 'a').valid?
  end

  it "validates_numericality_of" do
    Validatee.class_eval { validates_numericality_of :string }
    assert !Validatee.new(:string => 'a').valid?
    assert Validatee.new(:string => '1').valid?
  end

  it "validates_uniqueness_of (basic tests)" do
    Validatee.class_eval { validates_uniqueness_of :string }
    # make sure Validatee and Validatee::Translation table ids are not the same (for tests)
    10.times { Validatee::Translation.create :locale => "en" }
    validatee = Validatee.create!(:string => 'a')

    #create
    assert !Validatee.new(:string => 'a').valid?
    assert Validatee.new(:string => 'b').valid?
    Globalize.with_locale(:de) {
      assert Validatee.new(:string => 'a').valid?,
             "Validate with string 'a' was incorrectly considered invalid #{Validatee.first.attributes.inspect}"
    }

    # update
    Validatee.create!(:string => 'b')
    assert validatee.update_attributes(:string => 'a')
    assert !validatee.update_attributes(:string => 'b')
    Globalize.with_locale(:de) { assert validatee.update_attributes(:string => 'b') }

  end

  it "validates_uniqueness_of (with nested model)" do
    # nested model (to check for this: https://github.com/resolve/refinerycms/pull/1486 )
    Nested::NestedValidatee.class_eval { validates_uniqueness_of :string }
    nested_validatee = Nested::NestedValidatee.create!(:string => 'a')
    Nested::NestedValidatee.create!(:string => 'b')
    assert nested_validatee.update_attributes(:string => 'a')
    assert !nested_validatee.update_attributes(:string => 'b')
  end

  it "validates_uniqueness_of (with options[:scope])" do
    # uniqueness validation on translated attribute with scope
    ScopedValidatee.class_eval { validates_uniqueness_of :string, :scope => [:integer,:scope_string] }
    ScopedValidatee.create!(:string => 'c', :integer => 1, :scope_string => 'd')

    assert !ScopedValidatee.new(:string => 'c', :integer => 1, :scope_string => 'd').valid?

    assert ScopedValidatee.new(:string => 'c', :integer => 1, :scope_string => 'a').valid?
    assert ScopedValidatee.new(:string => 'c', :integer => 1).valid?
    assert ScopedValidatee.new(:string => 'c', :integer => 0, :scope_string => 'd').valid?
    assert ScopedValidatee.new(:string => 'c', :scope_string => 'd').valid?
    assert ScopedValidatee.new(:string => 'c', :integer => 0, :scope_string => 'a').valid?

    # check to make sure standard uniqueness validation still works
    ScopedValidatee.class_eval { validates_uniqueness_of :another_integer }
    ScopedValidatee.create!(:string => 'abc', :another_integer => 1)

    assert !ScopedValidatee.new(:another_integer => 1).valid?
    assert ScopedValidatee.new(:another_integer => 0).valid?
  end

  # it "validates_associated" do
  # end
end
