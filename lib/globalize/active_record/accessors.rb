module Globalize
  module ActiveRecord
    module Accessors
      def self.included(base)
        base.class_eval do
          translated_attribute_names.each do |attr_name|  
            Globalize.available_locales.each do |locale|
              define_method :"#{attr_name}_#{locale}" do
                read_attribute(attr_name, locale)
              end

              define_method :"#{attr_name}_#{locale}=" do |value|
                write_attribute(attr_name, value, locale)
              end
            end
          end 
        end
      end
    end
  end
end
