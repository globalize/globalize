# Gem load order is not guaranteed, so another gem's on_load(:active_record)
# hook can call `serialize` on a model before this one runs. Defining the
# attribute unconditionally here, rather than inside a hook, ensures it
# always exists before that happens.
ActiveRecord::Base.class_attribute :globalize_serialized_attributes, instance_writer: false
ActiveRecord::Base.globalize_serialized_attributes = {}

module Globalize
  module AttributeMethods
    module Serialization
      def serialize(attr_name, **options)
        self.globalize_serialized_attributes = globalize_serialized_attributes.dup
        self.globalize_serialized_attributes[attr_name] = options

        # https://github.com/rails/rails/blob/8-0-stable/activerecord/lib/active_record/attribute_methods/serialization.rb#L183
        super(attr_name, **options)
      end
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::Serialization)
