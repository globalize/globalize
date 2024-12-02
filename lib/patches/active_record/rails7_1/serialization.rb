module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, class_name_or_coder = nil, **options)
        self.globalize_serialized_attributes = globalize_serialized_attributes.dup

        if class_name_or_coder.nil?
          self.globalize_serialized_attributes[attr_name] = options

          super(attr_name, **options)
        elsif class_name_or_coder.is_a?(Hash)
          self.globalize_serialized_attributes[attr_name] = class_name_or_coder

          # https://github.com/rails/rails/blob/7-2-stable/activerecord/lib/active_record/attribute_methods/serialization.rb#L183
          super(attr_name, **class_name_or_coder)
        else
          self.globalize_serialized_attributes[attr_name] = [class_name_or_coder, options]

          # this is only needed for ACTIVE_RECORD_71. class_name_or_coder will be removed with Rails 7.2
          # https://github.com/rails/rails/blob/7-1-stable/activerecord/lib/active_record/attribute_methods/serialization.rb#L183
          super(attr_name, class_name_or_coder, **options)
        end
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)
