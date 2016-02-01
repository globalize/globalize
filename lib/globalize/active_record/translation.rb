module Globalize
  module ActiveRecord
    class Translation < ::ActiveRecord::Base

      validates :locale, :presence => true

      validate :uniqueness_of_translated_attribute, if: proc { combination_changed? }

      class << self
        # Sometimes ActiveRecord queries .table_exists? before the table name
        # has even been set which results in catastrophic failure.
        def table_exists?
          table_name.present? && super
        end

        def with_locales(*locales)
          # Avoid using "IN" with SQL queries when only using one locale.
          locales = locales.flatten.map(&:to_s)
          locales = locales.first if locales.one?
          where :locale => locales
        end
        alias with_locale with_locales

        def translated_locales
          select('DISTINCT locale').order(:locale).map(&:locale)
        end
      end

      def locale
        _locale = read_attribute :locale
        _locale.present? ? _locale.to_sym : _locale
      end

      def locale=(locale)
        write_attribute :locale, locale.to_s
      end

      private

      def uniqueness_of_translated_attribute
        if self.class.where(locale: locale, foreign_attribute => send(foreign_attribute)).count != 0
          errors.add(foreign_attribute)
        end
      end

      def combination_changed?
        locale_changed? || foreign_attribute_changed?
      end

      def foreign_attribute_changed?
        send("#{foreign_attribute}_changed?".to_sym)
      end

      def foreign_attribute
        self.class.reflections["globalized_model"].options[:foreign_key].to_sym
      end

    end
  end
end

# Setting this will force polymorphic associations to subclassed objects
# to use their table_name rather than the parent object's table name,
# which will allow you to get their models back in a more appropriate
# format.
#
# See http://www.ruby-forum.com/topic/159894 for details.
Globalize::ActiveRecord::Translation.abstract_class = true
