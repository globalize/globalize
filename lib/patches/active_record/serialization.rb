module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, *args, **kwargs)
        super.tap do
          self.globalize_serialized_attributes = globalize_serialized_attributes.dup
          self.globalize_serialized_attributes[attr_name] = { args: args, kwargs: kwargs }
        end
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)
