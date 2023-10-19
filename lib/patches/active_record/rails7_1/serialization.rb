module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, type: Object, **options)
        super(attr_name, type: type, **options)

        coder = if type == ::JSON
                  ::ActiveRecord::Coders::JSON
                elsif [:load, :dump].all? { |x| type.respond_to?(x) }
                  type
                else
                  ::ActiveRecord::Coders::YAMLColumn.new(attr_name, type)
                end

        self.globalize_serialized_attributes = globalize_serialized_attributes.dup
        self.globalize_serialized_attributes[attr_name] = coder
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)