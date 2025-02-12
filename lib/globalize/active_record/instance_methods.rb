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

      def attributes=(new_attributes, *options)
        super unless new_attributes.respond_to?(:stringify_keys) && new_attributes.present?
        attributes = new_attributes.stringify_keys
        with_given_locale(attributes) { super(attributes.except("locale"), *options) }
      end

      def _assign_attributes(new_attributes)
        attributes = new_attributes.stringify_keys
        with_given_locale(attributes) { super(attributes.except("locale")) }
      end

      def write_attribute(name, value, *args, &block)
        return super(name, value, *args, &block) unless translated?(name)

        options = {:locale => Globalize.locale}.merge(args.first || {})

        globalize.write(options[:locale], name, value)
      end

      def [](attr_name)
        if translated?(attr_name)
          read_attribute(attr_name)
        else
          read_attribute(attr_name) { |n| missing_attribute(n, caller) }
        end
      end

      def read_attribute(attr_name, options = {}, &block)
        name = if self.class.attribute_alias?(attr_name)
                 self.class.attribute_alias(attr_name).to_s
               else
                 attr_name.to_s
               end

        name = self.class.primary_key if name == "id".freeze && self.class.primary_key

        _read_attribute(name, options, &block)
      end

      def _read_attribute(attr_name, options = {}, &block)
        translated_value = read_translated_attribute(attr_name, options)
        translated_value.nil? ? super(attr_name, &block) : translated_value
      end

      def attribute_names
        translated_attribute_names.map(&:to_s) + super
      end

      delegate :translated?, :to => :class

      def translated_attributes
        translated_attribute_names.inject({}) do |attributes, name|
          attributes.merge(name.to_s => send(name))
        end
      end

      # This method is basically the method built into Rails
      # but we have to pass {:translated => false}
      def untranslated_attributes
        attribute_names.inject({}) do |attrs, name|
          attrs[name] = read_attribute(name, {:translated => false}); attrs
        end
      end

      def set_translations(options)
        options.keys.each do |locale|
          translation = translation_for(locale) ||
                        translations.build(:locale => locale.to_s)

          options[locale].each do |key, value|
            translation.send :"#{key}=", value
            translation.globalized_model.send :"#{key}=", value
          end
          translation.save if persisted?
        end
        globalize.reset
      end

      def reload(options = nil)
        translation_caches.clear
        translated_attribute_names.each { |name| @attributes.reset(name.to_s) }
        globalize.reset
        super(options)
      end

      def initialize_dup(other)
        @globalize = nil
        @translation_caches = nil
        super
        other.each_locale_and_translated_attribute do |locale, name|
          globalize.write(locale, name, other.globalize.fetch(locale, name) )
        end
      end

      def translation
        translation_for(::Globalize.locale)
      end

      def translation_for(locale, build_if_missing = true)
        unless translation_caches[locale]
          # Fetch translations from database as those in the translation collection may be incomplete
          _translation = translations.detect{|t| t.locale.to_s == locale.to_s}
          _translation ||= translations.with_locale(locale).first unless translations.loaded?
          _translation ||= translations.build(:locale => locale) if build_if_missing
          translation_caches[locale] = _translation if _translation
        end
        translation_caches[locale]
      end

      def translation_caches
        @translation_caches ||= {}
      end

      def translations_by_locale
        translations.each_with_object(HashWithIndifferentAccess.new) do |t, hash|
          hash[t.locale] = block_given? ? yield(t) : t
        end
      end

      def translated_attribute_by_locale(name)
        translations_by_locale(&:"#{name}")
      end

      # Get available locales from translations association, without a separate distinct query
      def available_locales
        translations.map(&:locale).uniq
      end

      def globalize_fallbacks(locale)
        Globalize.fallbacks(locale)
      end

      class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def save(...)
          result = Globalize.with_locale(translation.locale || I18n.default_locale) do
            without_fallbacks do
              super
            end
          end
          if result
            globalize.clear_dirty
          end

          result
        end
      RUBY

      def column_for_attribute name
        return super if translated_attribute_names.exclude?(name)

        globalize.send(:column_for_attribute, name)
      end

      def cache_key
        [super, translation.cache_key].join("/")
      end

      def changed?
        changed_attributes.present? || translations.any?(&:changed?)
      end

      def saved_changes
        super.tap do |changes|
          translation = translation_for(::Globalize.locale, false)
          if translation
            translation_changes = translation.saved_changes.select { |name| translated?(name) }
            changes.merge!(translation_changes) if translation_changes.any?
          end
        end
      end

      def changed_attributes
        super.merge(globalize.changed_attributes(::Globalize.locale))
      end

      def changes
        super.merge(globalize.changes(::Globalize.locale))
      end

      def changed
        super.concat(globalize.changed).uniq
      end

      # need to access instance variable directly since changed_attributes is frozen
      def original_changed_attributes
        @changed_attributes
      end

    protected

      def each_locale_and_translated_attribute
        used_locales.each do |locale|
          translated_attribute_names.each do |name|
            yield locale, name
          end
        end
      end

      def used_locales
        locales = globalize.stash.keys.concat(globalize.stash.keys).concat(translations.translated_locales)
        locales.uniq!
        locales
      end

      def save_translations!
        globalize.save_translations!
        translation_caches.clear
      end

      def with_given_locale(_attributes, &block)
        attributes = _attributes.stringify_keys

        if locale = attributes.try(:delete, "locale")
          Globalize.with_locale(locale, &block)
        else
          yield
        end
      end

      def without_fallbacks
        before = self.fallbacks_for_empty_translations
        self.fallbacks_for_empty_translations = false
        yield
      ensure
        self.fallbacks_for_empty_translations = before
      end

      # nil or value
      def read_translated_attribute(name, options)
        options = {:translated => true, :locale => nil}.merge(options)
        return nil unless options[:translated]
        return nil unless translated?(name)

        globalize.fetch(options[:locale] || Globalize.locale, name)
      end
    end
  end
end
