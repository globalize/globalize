module Globalize
  module ActiveRecord
    module ActMacro
      # Translated attributes
      # Example: 
      #   class Post < ActiveRecord::Base
      #     translates "title:string", "content:text", :versioning => true, :table_name => "..."
      #   end
      #
      def translates(*attr_columns)
        return if translates?

        options = attr_columns.extract_options!
        options[:table_name] ||= "#{table_name.singularize}_translations"
        
        attrs_hash = Utils.convert_columns(attr_columns)
        attr_names = attrs_hash.keys
        
        class_attribute :translated_attribute_names, :translation_options, 
                        :fallbacks_for_empty_translations, :translated_columns_hash
                        
        self.translated_attribute_names = attr_names.map(&:to_sym)
        self.translation_options        = options
        self.translated_columns_hash    = attrs_hash
        self.fallbacks_for_empty_translations = options[:fallbacks_for_empty_translations]

        include InstanceMethods, Accessors
        extend  ClassMethods, Migration

        has_many :translations, :class_name  => translation_class.name,
                                :foreign_key => class_name.foreign_key,
                                :dependent   => :destroy,
                                :extend      => HasManyExtensions

        before_save :update_checkers!
        after_create :save_translations!
        after_update :save_translations!

        if options[:versioning]
          ::ActiveRecord::Base.extend(Globalize::Versioning::PaperTrail)

          translation_class.has_paper_trail
          delegate :version, :versions, :to => :translation
        end

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
