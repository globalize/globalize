module Globalize
  module ActiveRecord
    module InstanceMethods
      delegate :translated_locales, :to => :translations

      def globalize
        @globalize ||= Adapter.new(self)
      end

      def attributes
        super.merge(translated_attributes)
      end

      def attributes=(attributes, *args)
        with_given_locale(attributes) { super }
      end

      def update_attributes!(attributes, *args)
        with_given_locale(attributes) { super }
      end

      def update_attributes(attributes, *args)
        with_given_locale(attributes) { super }
      end

      def write_attribute(name, value, locale = nil)
        locale ||= Globalize.locale
        
        if translates_attribute?(name, locale)        
          globalize.write(locale, name, value)
        else
          super(name, value)
        end
      end

      def read_attribute(name, locale = nil)
        locale ||= Globalize.locale
        
        if translates_attribute?(name, locale)
          globalize.fetch(locale, name)
        else
          super(name)
        end
      end
          
      def attribute_names
        translated_attribute_names.map(&:to_s) + super
      end
      
      def translated?(name)
        self.class.translated?(name)
      end
      
      def translates_attribute?(name, locale = nil)
        locale ||= Globalize.locale
        self.class.translated?(name) && I18n.default_locale.to_s != locale.to_s
      end

      def translated_attributes
        translated_attribute_names.inject({}) do |attributes, name|
          attributes.merge(name.to_s => send(name))
        end
      end

      def set_translations(options)
        options.keys.each do |locale|
          translation = translations.find_by_locale(locale.to_s) ||
            translations.build(:locale => locale.to_s)
          translation.update_attributes!(options[locale])
        end
      end

      def reload(options = nil)
        translated_attribute_names.each { |name| @attributes.delete(name.to_s) }
        globalize.reset
        super(options)
      end

      protected

        def save_translations!
          globalize.save_translations!
        end

        def with_given_locale(attributes, &block)
          attributes.symbolize_keys! if attributes.respond_to?(:symbolize_keys!)
          if locale = attributes.try(:delete, :locale)
            Globalize.with_locale(locale, &block)
          else
            yield
          end
        end
    end
  end
end
