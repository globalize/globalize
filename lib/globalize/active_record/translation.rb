module Globalize
  module ActiveRecord
    class Translation < ::Mobility::ActiveRecord::ModelTranslation
      self.abstract_class = true

      class << self
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
    end
  end
end
