module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, class_name_or_coder = Object)
        super(attr_name, class_name_or_coder)

        coder = if class_name_or_coder == ::JSON
                  ::ActiveRecord::Coders::JSON
                elsif [:load, :dump].all? { |x| class_name_or_coder.respond_to?(x) }
                  class_name_or_coder
                else
                  ::ActiveRecord::Coders::YAMLColumn.new(class_name_or_coder)
                end

        self.globalize_serialized_attributes[attr_name] = coder
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)