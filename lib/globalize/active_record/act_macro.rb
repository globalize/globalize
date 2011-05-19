module Globalize
  module ActiveRecord
    module ActMacro
      def translates(*attr_names)
        return if translates?

        options = attr_names.extract_options!
        options[:table_name] ||= "#{table_name.singularize}_translations"

        class_attribute :translated_attribute_names, :translation_options
        self.translated_attribute_names = attr_names.map(&:to_sym)
        self.translation_options        = options

        include InstanceMethods
        extend  ClassMethods, Migration

        has_many :translations, :class_name  => translation_class.name,
                                :foreign_key => class_name.foreign_key,
                                :dependent   => :destroy,
                                :extend      => HasManyExtensions

        after_create :save_translations!
        after_update :save_translations!

        attr_names.each { |attr_name| translated_attr_accessor(attr_name) }
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
    end

    module HasManyExtensions
      def find_or_initialize_by_locale(locale)
        with_locale(locale.to_s).first || build(:locale => locale.to_s)
      end
    end
  end
end
