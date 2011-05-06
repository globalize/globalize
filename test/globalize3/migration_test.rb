require File.expand_path('../../test_helper', __FILE__)

class MigrationTest < Test::Unit::TestCase
  include Globalize::ActiveRecord::Exceptions

  def setup
    super
    reset_schema(Migrated, MigratedWithUltraLongModelName)
    assert !Migrated::Translation.table_exists?
    assert !Migrated::Translation.index_exists_on?(:migrated_id)
  end

  def teardown
    reset_schema(Migrated, MigratedWithUltraLongModelName)
  end

  test 'create_translation_table!(:name => :text) adds the translations table' do
    Migrated.create_translation_table!(:name => :text)
    assert_migration_table(:name => :text)
  end

  test 'create_translation_table! adds the translations table using the column type from the translated model' do
    Migrated.create_translation_table!
    assert_migration_table(:name => :string)
  end

  test 'create_translation_table! can not be called on non-translated models' do
    assert_raise NoMethodError do
      Blog.create_translation_table!(:name => :string)
    end
  end

  test 'passing a non-translated field name raises BadFieldName' do
    assert_raise BadFieldName do
      Migrated.create_translation_table!(:content => :text)
    end
  end

  test 'passing a translated field with a wrong type raises BadFieldType' do
    assert_raise BadFieldType do
      Migrated.create_translation_table!(:name => :integer)
    end
  end

  test 'drop_translation_table! drops the translations table' do
    Migrated.create_translation_table!(:name => :string)
    assert Migrated::Translation.table_exists?
    assert Migrated::Translation.index_exists_on?(:migrated_id)

    Migrated.drop_translation_table!
    assert !Migrated::Translation.table_exists?
    assert !Migrated::Translation.index_exists_on?(:migrated_id)
  end

  test 'drop_translation_table! can not be called on non-translated models' do
    assert_raise NoMethodError do
      Blog.drop_translation_table!
    end
  end

  test "translation_index_name returns a readable index name if it's not longer than 50 characters" do
    assert_equal 'index_migrated_translations_on_migrated_id', Migrated.send(:translation_index_name)
  end

  test "translation_index_name returns a hashed index name if it's longer than 50 characters" do
    assert_match /^index_[a-z0-9]{40}$/, MigratedWithUltraLongModelName.send(:translation_index_name)
  end

  test 'create_translation_table! can deal with ultra long table names' do
    model = MigratedWithUltraLongModelName
    model.create_translation_table!(:name => :string)

    assert model::Translation.table_exists?
    assert model::Translation.index_exists?(model.send(:translation_index_name))
  end

  test 'drop_translation_table! can deal with ultra long table names' do
    model = MigratedWithUltraLongModelName
    model.create_translation_table!(:name => :string)
    model.drop_translation_table!

    assert !model::Translation.table_exists?
    assert !model::Translation.index_exists?(:ultra_long_model_name_without_proper_id)
  end

  # This test is relatively exhaustive in that it tests the full stack of
  # create_translation_table! and its ability to use migrate_data to migrate
  # non translated data into the default Globalize locale.
  # We are then testing the ability of drop_translation_table! to migrate the
  # translated data from the default Globalize locale back as untranslated data.
  test 'create_translation_table! with option migrate_data set to true DOES migrate existing data AND rolls back' do
    # Ensure we have a "Fresh" version. Can't use reset_schema because it's not a translated model, yet.
    model = Untranslated
    model.drop_translation_table! if model.respond_to?(:drop_translation_table!)
    model.reset_column_information rescue nil

    # First create an untranslated record
    untranslated = model.create! :name => 'Untranslated'

    # Now add translation support and migrate (also tests .untranslated_attributes)
    model.instance_eval %{ translates :name }
    model.create_translation_table!({:name => :string}, {:migrate_data => true})
    assert model::Translation.table_exists?

    # Reload the untranslated record
    untranslated.reload

    # Was it migrated?
    assert_translated untranslated, :en, :name, 'Untranslated'

    # Cool, now we need to get rid of the non-translated value for the next test
    model.update_all({:name => 'No longer translated'}, :id => untranslated.id)
    untranslated.reload

    # Make sure we didn't harm the translation and that it's been set. (also tests .untranslated_attributes)
    assert_equal 'No longer translated', untranslated.untranslated_attributes['name']
    assert_translated untranslated, :en, :name, 'Untranslated'

    # Now we need to rollback then undo
    model.drop_translation_table! :migrate_data => true
    model.reset_column_information rescue nil
    assert !model::Translation.table_exists?
    untranslated.reload

    # Was it restored? (also tests .untranslated_attributes)
    assert_equal 'Untranslated', untranslated.untranslated_attributes['name']
  end

protected

  def reset_schema(*models)
    models.each do |model|
      model.reset_column_information rescue nil
      model::Translation.reset_column_information rescue nil
      model.drop_translation_table! if model::Translation.table_exists?
    end
  end

  def column_type(name)
    Migrated::Translation.columns.detect { |c| c.name == name.to_s }.try(:type)
  end

  def assert_migration_table(fields)
    assert Migrated::Translation.table_exists?
    assert Migrated::Translation.index_exists_on?(:migrated_id)

    assert_equal :string,   column_type(:locale)
    assert_equal :integer,  column_type(:migrated_id)
    assert_equal :datetime, column_type(:created_at)
    assert_equal :datetime, column_type(:updated_at)

    fields.each do |name, type|
      assert_equal type, column_type(name)
    end
  end
end
