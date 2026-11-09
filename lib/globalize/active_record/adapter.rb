module Globalize
  module ActiveRecord
    class Adapter
      # The cache caches attributes that already were looked up for read access.
      # The stash keeps track of new or changed values that need to be saved.
      attr_accessor :record, :stash
      private :record=, :stash=

      delegate :translation_class, :to => :'record.class'

      def initialize(record)
        @record = record
        @stash = Attributes.new
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
            return value
          end
        end

        return nil
      end

      def save_translations!
        stash.each do |locale, attrs|
          next if attrs.empty?

          translation = record.translations_by_locale[locale] ||
                        record.translations.build(locale: locale.to_s)
          attrs.each do |name, value|
            value = value.val if value.is_a?(Arel::Nodes::Casted)
            translation[name] = value
          end

          ensure_foreign_key_for(translation)
          translation.save!
        end

        reset
      end

      def reset
        stash.clear
      end

      def foreign_key_values(in_database: false)
        reflection = record.class.reflect_on_association(:translations)
        foreign_key = Array(reflection.foreign_key)
        primary_key = Array(reflection.active_record_primary_key)
        # Checked here as query constraints can come after `translates`, or never.
        unless foreign_key.size == primary_key.size
          raise ArgumentError, "#{record.class.name} needs query constraints with a column for each " \
            "of its translations' foreign key columns (#{foreign_key.join(", ")})."
        end

        foreign_key.zip(primary_key).to_h do |column, key|
          # These read the column, where `[]` reads "id" as the whole primary key.
          [column, in_database ? record.attribute_in_database(key) : record._read_attribute(key)]
        end
      end

      protected

      # Sometimes the translation is initialised before a foreign key can be set.
      def ensure_foreign_key_for(translation)
        translation.assign_attributes(foreign_key_values)
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
        if translation
          translation.send(name)
        else
          record.class.translation_class.new.send(name)
        end
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
      prepend AdapterDirty
    end
  end
end
