module Globalize
  module ActiveRecord
    module ActMacro
      def translates(*attr_names)
        options = attr_names.extract_options!
        # Bypass setup_translates! if the initial bootstrapping is done already.
        setup_translates!(options) unless translates?
        check_columns!(attr_names)

        # Add any extra translatable attributes.
        attr_names = attr_names.map(&:to_sym)
        attr_names -= translated_attribute_names if defined?(translated_attribute_names)

        allow_translation_of_attributes(attr_names) if attr_names.present?
      end

      def class_name
        @class_name ||= begin
          class_name = table_name[table_name_prefix.length..-(table_name_suffix.length + 1)].downcase.camelize
          pluralize_table_names ? class_name.singularize : class_name
        end
      end

      def translates?
        included_modules.include?(InstanceMethods)
      end

      protected

      def allow_translation_of_attributes(attr_names)
        attr_names.each do |attr_name|
          # Detect and apply serialization.
          enable_serializable_attribute(attr_name)

          # Create accessors for the attribute.
          define_translated_attr_accessor(attr_name)
          define_translations_accessor(attr_name)

          # Add attribute to the list.
          self.translated_attribute_names << attr_name
        end

        begin
          if ::ActiveRecord::VERSION::STRING > "5.0" && table_exists? && translation_class.table_exists?
            self.ignored_columns += translated_attribute_names.map(&:to_s)
            reset_column_information
          end
        rescue ::ActiveRecord::NoDatabaseError
          warn 'Unable to connect to a database. Globalize skipped ignoring columns of translated attributes.'
        end
      end

      def check_columns!(attr_names)
        # If tables do not exist or Rails version is greater than 5, do not warn about conflicting columns
        return unless ::ActiveRecord::VERSION::STRING < "5.0" && table_exists? && translation_class.table_exists?
        if (overlap = attr_names.map(&:to_s) & column_names).present?
          ActiveSupport::Deprecation.warn(
            ["You have defined one or more translated attributes with names that conflict with column(s) on the model table. ",
             "Globalize does not support this configuration anymore, remove or rename column(s) on the model table.\n",
             "Model name (table name): #{model_name} (#{table_name})\n",
             "Attribute name(s): #{overlap.join(', ')}\n"].join
          )
        end
      rescue ::ActiveRecord::NoDatabaseError
        warn 'Unable to connect to a database. Globalize skipped checking attributes with conflicting column names.'
      end

      def apply_globalize_options(options)
        options[:table_name] ||= "#{table_name.singularize}_translations"
        options[:foreign_key] ||= class_name.foreign_key

        class_attribute :translated_attribute_names, :translation_options, :fallbacks_for_empty_translations
        self.translated_attribute_names = []
        self.translation_options        = options
        self.fallbacks_for_empty_translations = options[:fallbacks_for_empty_translations]
      end

      def enable_serializable_attribute(attr_name)
        serializer = self.globalize_serialized_attributes[attr_name]
        if serializer.present?
          if defined?(::ActiveRecord::Coders::YAMLColumn) &&
            serializer.is_a?(::ActiveRecord::Coders::YAMLColumn)
            serializer = serializer.object_class
          end

          translation_class.send :serialize, attr_name, serializer
        end
      end

      def setup_translates!(options)
        apply_globalize_options(options)

        include InstanceMethods
        extend  ClassMethods, Migration

        translation_class.table_name = options[:table_name]

        has_many :translations, :class_name  => translation_class.name,
                                :foreign_key => options[:foreign_key],
                                :dependent   => :destroy,
                                :extend      => HasManyExtensions,
                                :autosave    => false,
                                :inverse_of  => :globalized_model

        after_create :save_translations!
        after_update :save_translations!
      end
    end

    module HasManyExtensions
      def find_or_initialize_by_locale(locale)
        with_locale(locale.to_s).first || build(:locale => locale.to_s)
      end
    end
  end
end
