module Globalize
  module Inflections
    # Guard against +I18n.fallbacks+ not being defined (#788) and defer to
    # the original implementation otherwise.
    def instance_or_fallback(locale)
      return instance(locale) unless I18n.respond_to?(:fallbacks)

      super
    end
  end
end

ActiveSupport::Inflector::Inflections.singleton_class.send :prepend, Globalize::Inflections
