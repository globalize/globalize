module Globalize
  module Inflections
    def instance_or_fallback(locale)
      I18n.respond_to?(:fallbacks) && I18n.fallbacks[locale].each do |k|
        return @__instance__[k] if @__instance__.key?(k)
      end
      instance(locale)
    end
  end
end

ActiveSupport::Inflector::Inflections.singleton_class.send :prepend, Globalize::Inflections
