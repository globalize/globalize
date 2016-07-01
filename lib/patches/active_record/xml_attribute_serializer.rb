begin
  require 'active_record/serializers/xml_serializer'
rescue LoadError
end

module Globalize
  module XmlSerializer
    module Attribute
      def compute_type
        klass = @serializable.class
        if klass.translates? && klass.translated_attribute_names.include?(name.to_sym)
          :string
        else
          super
        end
      end
    end
  end
end

if defined?(ActiveRecord::XmlSerializer)
  ActiveRecord::XmlSerializer::Attribute.send(:prepend, Globalize::XmlSerializer::Attribute)
end
