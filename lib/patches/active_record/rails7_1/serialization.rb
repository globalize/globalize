module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, class_name_or_coder = nil, **options)
        super(attr_name, **options)

        coder = if class_name_or_coder == ::JSON
                  ::ActiveRecord::Coders::JSON
                else
                  ::ActiveRecord::Coders::YAMLColumn.new(attr_name)
                end

        self.globalize_serialized_attributes = globalize_serialized_attributes.dup
        self.globalize_serialized_attributes[attr_name] = coder
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)
