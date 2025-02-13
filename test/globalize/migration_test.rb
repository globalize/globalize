require File.expand_path('../../test_helper', __FILE__)

class MigrationTest < Minitest::Spec
  include Globalize::ActiveRecord::Exceptions

  before(:each) do
    reset_schema(Migrated, TwoAttributesMigrated, MigratedBigint)
    if Globalize::Test::Database.long_table_name_support?
      reset_schema(MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters)
    end
    refute Migrated.translation_class.table_exists?
    refute Migrated.translation_class.index_exists_on?(:migrated_id)
    refute Migrated.translation_class.index_exists_on?(:locale)
  end

  after(:each) do
    reset_schema(Migrated, TwoAttributesMigrated, MigratedBigint)
    if Globalize::Test::Database.long_table_name_support?
      reset_schema(MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters)
    end
  end

  describe 'create_translation_table!' do
    it 'adds the translations table with name and type' do
      Migrated.create_translation_table!(:name => :text)
      assert_migration_table(:name => :text)
    end

    it 'uses the column type from the translated model if no options passed in' do
      Migrated.create_translation_table!
      assert_migration_table(:name => :string)
    end

    it 'can not be called on non-translated models' do
      assert_raises NoMethodError do
        Blog.create_translation_table!(:name => :string)
      end
    end

    it 'adds the translations table with options' do
      unless Globalize::Test::Database.mysql?
        Migrated.create_translation_table!(:name => {:type => :text, :default => '123'})
        assert_migration_table(:name => :text)
        assert_equal '123', column_default(:name)
      end
    end

    it 'raises BadFieldName if passed non-translated field name' do
      assert_raises BadFieldName do
        Migrated.create_translation_table!(:content => :text)
      end
    end

    it 'avoids creating all translated attributes if translated attributes specified' do
      TwoAttributesMigrated.create_translation_table!(:name => :string)
      assert_migration_table({:name => :string}, TwoAttributesMigrated)
      assert_nil column_type(:body, TwoAttributesMigrated)
    end

    it 'handles ultra-long table names' do
      return unless Globalize::Test::Database.long_table_name_support?
      model = MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters
      model.create_translation_table!(:name => :string)

      assert model.translation_class.table_exists?
      assert model.translation_class.index_exists?(model.send(:translation_index_name))
      assert model.translation_class.index_exists?(model.send(:translation_locale_index_name))
    end

    # This test is relatively exhaustive in that it tests the full stack of
    # create_translation_table! and its ability to use migrate_data to migrate
    # non translated data into the default Globalize locale.
    # We are then testing the ability of drop_translation_table! to migrate the
    # translated data from the default Globalize locale back as untranslated data.
    it 'migrates existing data and correctly rolls back when called with :migrate_data => true' do
      strategy = Globalize::Test::Database.mysql? ? :truncation : :transaction
      Globalize::Test::Database.cleaning_strategy(strategy) do
        # Ensure we have a "Fresh" version. Can't use reset_schema because it's not a translated model, yet.
        model = Untranslated
        drop_model_translation_table!(model)
        model.reset_column_information

        # First create an untranslated record
        untranslated = model.create! :name => 'Untranslated'

        # Now add translation support and migrate (also tests .untranslated_attributes)
        model.instance_eval %{ translates :name }


        I18n.with_locale(:fr) do
          model.create_translation_table!({:name => :string}, {:migrate_data => true})
        end
        assert model.translation_class.table_exists?

        # Reload the untranslated record
        untranslated.reload

        # Was it migrated?
        assert_translated untranslated, :fr, :name, 'Untranslated'

        # Cool, now we need to get rid of the non-translated value for the next test
        model.where(:id => untranslated.id).update_all(:name => 'No longer translated')
        untranslated.reload

        # Make sure we didn't harm the translation and that it's been set. (also tests .untranslated_attributes)
        assert_equal 'No longer translated', untranslated.untranslated_attributes['name']
        assert_translated untranslated, :fr, :name, 'Untranslated'

        # Now we need to rollback then undo
        I18n.with_locale(:fr) do
          model.drop_translation_table! :migrate_data => true
        end
        model.reset_column_information
        assert !model.translation_class.table_exists?
        untranslated.reload

        # Was it restored? (also tests .untranslated_attributes)
        assert_equal 'Untranslated', untranslated.untranslated_attributes['name']
      end
    end

    it 'creates a proper types for FK ids' do
      MigratedBigint.create_translation_table!(:name => :text)
      assert_migration_table({}, MigratedBigint)
    end
  end

  describe 'add_translation_fields!' do
    it 'adds fields to translate after creating the translation table' do
      TwoAttributesMigrated.create_translation_table!(:name => :string)
      TwoAttributesMigrated.add_translation_fields!(:body => :text)
      assert_migration_table({:name => :string, :body => :text}, TwoAttributesMigrated)
    end

    # Here we test that adding translation fields we can use the migrate data and remouve source column options.
    # * First, we get a model with no translation and create a record,
    # * Then, we translate both fields and create translation table just for one of them migrating data
    # * Then we add the other field to the translation table, migrate data and remove the source column
    # * Finally we check that data has been migrated, we haven't overwritten the old migrated data and there's no source column
    it 'migrates existing data but does not remove old migrated data when called with :migrate_data => true' do
      strategy = Globalize::Test::Database.mysql? ? :truncation : :transaction
      Globalize::Test::Database.cleaning_strategy(strategy) do
        model = TwoAttributesUntranslated
        drop_model_translation_table!(model)
        model.reset_column_information

        untranslated_record = model.create! :name => 'Untranslated', :body => "Untranslated body"

        model.instance_eval %{ translates :name, :body }

        model.create_translation_table!({:name => :string}, {:migrate_data => true})

        untranslated_record.reload

        # We change the untranslated value so we make sure we don't overwrite the translated one when we add new fields
        model.where(:id => untranslated_record.id).update_all(:name => 'No longer translated')
        untranslated_record.reload

        model.add_translation_fields!({:body => :text}, {:migrate_data => true, :remove_source_columns => true})
        untranslated_record.reload

        assert_translated untranslated_record, :en, :name, 'Untranslated'
        assert_translated untranslated_record, :en, :body, 'Untranslated body'

        assert_nil model.columns.detect { |c| c.name == "body" }
      end
    end
  end

  describe 'drop_translation_table!' do
    it 'drops the translations table' do
      Migrated.create_translation_table!(:name => :string)
      assert Migrated.translation_class.table_exists?
      assert Migrated.translation_class.index_exists_on?(:migrated_id)
      assert Migrated.translation_class.index_exists_on?(:locale)
      refute Migrated.translation_class.unique_index_exists_on?('migrated_id', 'locale')

      Migrated.drop_translation_table!
      assert !Migrated.translation_class.table_exists?
      assert !Migrated.translation_class.index_exists_on?(:migrated_id)
      assert !Migrated.translation_class.index_exists_on?(:locale)
    end

    it 'create source columns on drops the translations table' do
      column_before = Migrated.columns.detect { |c| c.name == 'name' }

      Migrated.create_translation_table!({:name => :string}, :remove_source_columns => true)
      Migrated.drop_translation_table!(:create_source_columns => true)

      column = Migrated.columns.detect { |c| c.name == 'name' }
      assert_equal column_before.try(:type), column.try(:type)
    end

    it 'cannot be called on non-translated models' do
      assert_raises NoMethodError do
        Blog.drop_translation_table!
      end
    end

    it 'handles ultra-long table names' do
      return unless Globalize::Test::Database.long_table_name_support?
      model = MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters
      model.create_translation_table!(:name => :string)
      model.drop_translation_table!

      assert !model.translation_class.table_exists?
      assert !model.translation_class.index_exists?(:ultra_long_model_name_without_proper_id)
    end
  end

  describe 'translation_index_name' do
    it "translation_index_name returns a readable index name if it's not longer than 64 characters" do
      assert_equal 'index_migrated_translations_on_migrated_id', Migrated.send(:translation_index_name)
    end

    it "returns a hashed index name if it's longer than 64 characters" do
      assert_match(/^index_[a-z0-9]{40}$/, MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters.send(:translation_index_name))
    end
  end

  describe 'translation :unique_index option' do
    it 'creates a unique index on the locale and foreign key' do
      Migrated.create_translation_table!({ :name => :string }, { unique_index: true })
      assert Migrated.translation_class.unique_index_exists_on?('migrated_id', 'locale')
    end
  end

  describe 'translation_locale_index_name' do
    it "returns a readable index name if class name is no longer than 64 characters" do
      assert_equal 'index_migrated_translations_on_locale', Migrated.send(:translation_locale_index_name)
    end

    it "returns a hashed index name if class name is longer than 64 characters" do
      assert_match(/^index_[a-z0-9]{40}$/, MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters.send(:translation_locale_index_name))
    end
  end

  describe 'options validation' do
    it 'raises an argument error when given unknown options' do
      e = assert_raises ArgumentError do
        Migrated.create_translation_table!({ :name => :string }, { migrate_data: true, uniq_index: true })
      end
      assert_equal 'Unknown migration option: [:uniq_index]', e.message
    end
  end

protected

  def drop_model_translation_table!(model)
    table_name = "#{model.name.underscore}_translations"

    if ActiveRecord::Base.connection.data_source_exists? table_name
      ActiveRecord::Migration.drop_table table_name
    end
  end

  def reset_schema(*models)
    models.each do |model|
      model.reset_column_information
      model.translation_class.reset_column_information
      model.drop_translation_table! if model.translation_class.table_exists?
    end
  end

  def column_type(name, model = Migrated)
    model.translation_class.columns.detect { |c| c.name == name.to_s }.try(:type)
  end

  def column_default(name, model = Migrated)
    model.translation_class.columns.detect { |c| c.name == name.to_s }.try(:default)
  end

  def assert_migration_table(fields, model = Migrated)
    index_field = :"#{model.class_name.underscore}_id"
    assert model.translation_class.table_exists?
    assert model.translation_class.index_exists_on?(index_field)

    assert_equal :string,   column_type(:locale, model)
    assert_equal model.type_for_attribute(model.primary_key), model.translation_class.type_for_attribute(index_field.to_s)
    assert_equal :datetime, column_type(:created_at, model)
    assert_equal :datetime, column_type(:updated_at, model)

    fields.each do |name, type|
      assert_equal type, column_type(name, model)
    end
  end
end
