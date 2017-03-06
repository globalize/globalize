require 'rubygems'
require 'bundler/setup'

Bundler.require(:default, :test)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

Globalize::Test::Database.connect

require File.expand_path('../data/models', __FILE__)
require 'minitest/autorun'
require 'minitest/reporters'
Minitest::Reporters.use!

require 'minitest/spec'

I18n.enforce_available_locales = true
I18n.available_locales = [ :en, :'en-US', :fr, :de, :'de-DE', :he, :nl, :pl ]

require 'database_cleaner'
DatabaseCleaner.strategy = :transaction

class MiniTest::Spec
  before :each do
    DatabaseCleaner.start
    I18n.locale = I18n.default_locale = :en
    Globalize.locale = nil
  end

  after :each do
    DatabaseCleaner.clean
  end

  delegate :with_locale, to: Globalize

  def with_fallbacks
    previous = I18n.backend
    I18n.backend = BackendWithFallbacks.new
    I18n.pretend_fallbacks
    return yield
  ensure
    I18n.hide_fallbacks
    I18n.backend = previous
  end

  def assert_belongs_to(model, other)
    assert_association(model, :belongs_to, other)
  end

  def assert_has_many(model, other)
    assert_association(model, :has_many, other)
  end

  def assert_association(model, type, other)
    assert model.reflect_on_all_associations(type).any? { |a| a.name == other }
  end

  def assert_translated(record, locale, attributes, translations)
    assert_equal Array.wrap(translations), Array.wrap(attributes).map { |name| record.send(name, locale) }
  end
end

ActiveRecord::Base.class_eval do
  class << self
    def index_exists?(index_name)
      connection.indexes(table_name).any? { |index| index.name == index_name.to_s }
    rescue ActiveRecord::StatementInvalid
      false
    end

    def index_exists_on?(column_name)
      connection.indexes(table_name).any? { |index| index.columns == [column_name.to_s] }
    rescue ActiveRecord::StatementInvalid
      false
    end

    def unique_index_exists_on?(*columns)
      connection.indexes(table_name).any? { |index| index.columns == columns && index.unique }
    end
  end
end

class BackendWithFallbacks < I18n::Backend::Simple
  include I18n::Backend::Fallbacks
end

meta = class << I18n; self; end
meta.class_eval do
  alias_method(:alternatives, :fallbacks)

  def pretend_fallbacks
    class << I18n; self; end.send(:alias_method, :fallbacks, :alternatives)
  end

  def hide_fallbacks
    class << I18n; self; end.send(:remove_method, :fallbacks)
  end
end

I18n.hide_fallbacks
