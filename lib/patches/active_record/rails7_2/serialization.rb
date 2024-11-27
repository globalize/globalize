module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, **options)
        self.globalize_serialized_attributes = globalize_serialized_attributes.dup
        self.globalize_serialized_attributes[attr_name] = options

        # https://github.com/rails/rails/blob/7-2-stable/activerecord/lib/active_record/attribute_methods/serialization.rb#L183
        super(attr_name, **options)
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)
