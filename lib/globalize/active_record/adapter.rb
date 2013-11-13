module Globalize
  module ActiveRecord
    class Adapter
      # The cache caches attributes that already were looked up for read access.
      # The stash keeps track of new or changed values that need to be saved.
      attr_accessor :record, :stash, :translations, :fallback_translations
      private :record=, :stash=, :fallback_translations=

      delegate :translation_class, :to => :'record.class'

      def initialize(record)
        @record = record
        @stash = Attributes.new
        @fallback_translations = Attributes.new
      end

      def fetch_stash(locale, name)
        stash.read(locale, name)
      end

      delegate :contains?, :to => :stash, :prefix => :stash
      delegate :write, :to => :stash

      def fetch(locale, name)
        record.globalize_fallbacks(locale).each do |fallback|
          value = stash.contains?(fallback, name) ? fetch_stash(fallback, name) : fetch_attribute(fallback, name)

          unless fallbacks_for?(value)
            set_metadata(value, :locale => fallback, :requested_locale => locale)
            if locale == fallback
              fallback_translations.destroy(locale, name) if fallback_translations.contains?(locale, name)
            else
              fallback_translations.write(locale, name, value)
            end
            return value
          end
        end

        return nil
      end

      def save_translations!
        existing_translations_by_locale = Hash[record.translations.map { |t| [ t.locale, t ] }]
        stash.reject {|locale, attrs| attrs.empty?}.each do |locale, attrs|
          translation = existing_translations_by_locale[locale] ||
                          record.translations.build(locale: locale.to_s)
          attrs.each { |name, value| translation[name] = fallback_translations.contains?(locale, name) ? nil : value }
          ensure_foreign_key_for(translation)
          translation.save!
        end

        reset
      end

      def reset
        stash.clear
      end

      protected

      def ensure_foreign_key_for(translation)
        # Sometimes the translation is initialised before a foreign key can be set.
        translation[translation.reflections[:globalized_model].foreign_key] = record.id
      end

      def type_cast(name, value)
        return value.presence unless column = column_for_attribute(name)

        column.type_cast value
      end

      def column_for_attribute(name)
        translation_class.columns_hash[name.to_s]
      end

      def unserializable_attribute?(name, column)
        column.text? && translation_class.serialized_attributes[name.to_s]
      end

      def fetch_attribute(locale, name)
        translation = record.translation_for(locale, false)
        return translation && translation.send(name)
      end

      def set_metadata(object, metadata)
        object.translation_metadata.merge!(metadata) if object.respond_to?(:translation_metadata)
        object
      end

      def translation_metadata_accessor(object)
        return if obj.respond_to?(:translation_metadata)
        class << object; attr_accessor :translation_metadata end
        object.translation_metadata ||= {}
      end

      def fallbacks_for?(object)
        object.nil? || (fallbacks_for_empty_translations? && object.blank?)
      end

      delegate :fallbacks_for_empty_translations?, :to => :record, :prefix => false
    end
  end
end
