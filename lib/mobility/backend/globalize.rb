module Mobility
  module Backend
    class Globalize < ::Mobility::Backend::ActiveRecord::Table
      setup do |attributes, options|
        alias_method :translation_caches, :__translations_cache

        define_singleton_method :translation_class do
          @translation_class ||= const_get(options[:subclass_name])
        end

        class << self
          def column_for_attribute(name)
            translation_class.columns_hash[name.to_s]
          end

          def translated?(name)
            translated_attribute_names.include?(name.to_sym)
          end
        end

        def translations_by_locale
          translations.each_with_object(HashWithIndifferentAccess.new) do |t, hash|
            hash[t.locale] = block_given? ? yield(t) : t
          end
        end

        def translated_attribute_by_locale(name)
          translations_by_locale(&:"#{name}")
        end

        def available_locales
          translations.map(&:locale).uniq
        end

        def attributes=(new_attributes, *options)
          super unless new_attributes.respond_to?(:stringify_keys) && new_attributes.present?
          attributes = new_attributes.stringify_keys
          with_given_locale(attributes) { super(attributes.except("locale"), *options) }
        end

        def attribute_names
          translated_attribute_names + super
        end

        def assign_attributes(new_attributes, *options)
          super unless new_attributes.respond_to?(:stringify_keys) && new_attributes.present?
          attributes = new_attributes.stringify_keys
          with_given_locale(attributes) { super(attributes.except("locale"), *options) }
        end

        attributes.each do |attribute|
          define_method(:"#{attribute}_translations") do
            Hash[translations.map { |translation| [translation.locale.to_s, translation.send(attribute)] }]
          end

          define_method(:"#{attribute}_translations=") do |value|
            value.each do |(locale, _value)|
              mobility_backend_for(attribute).write(locale.to_sym, _value)
            end
          end

          alias_method "#{attribute}_before_type_cast", attribute
        end

        protected

        def with_given_locale(attributes_, &block)
          attributes = attributes_.stringify_keys

          if locale = attributes.try(:delete, "locale")
            ::Globalize.with_locale(locale, &block)
          else
            yield
          end
        end
      end

      def self.configure!(options)
        model_class = options[:model_class]
        table_name = model_class.table_name
        options[:table_name]  ||= "#{table_name.singularize}_translations".freeze
        options[:foreign_key] ||= table_name.downcase.singularize.camelize.foreign_key
        options[:association_name] = :translations
        options[:dirty] = true
        options[:locale_accessors] = true
        subclass_name = options[:subclass_name] = :Translation
        model_class.const_set(subclass_name, Class.new(::Globalize::ActiveRecord::Translation)) unless model_class.const_defined?(subclass_name, false)
        %i[foreign_key association_name subclass_name].each { |key| options[key] = options[key].to_sym }
      end
    end
  end
end
