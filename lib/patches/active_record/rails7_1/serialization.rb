module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, class_name_or_coder = Object, **options)
        if class_name_or_coder == ::JSON || [:load, :dump].all? { |x| class_name_or_coder.respond_to?(x) }
          options = options.merge(coder: class_name_or_coder, type: Object)
        else
          options = options.merge(coder: default_column_serializer, type: class_name_or_coder)
        end

        super(attr_name, **options)

        coder = build_column_serializer(attr_name, options[:coder], options[:type], options[:yaml])

        self.globalize_serialized_attributes = globalize_serialized_attributes.dup
        self.globalize_serialized_attributes[attr_name] = coder
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)