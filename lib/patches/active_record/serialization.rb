module Globalize
  module AttributeMethods
    # Storage for the serialization options Globalize replays onto translation
    # classes in +ActMacro#enable_serializable_attribute+.
    #
    # These accessors are deliberately defined here, in a module prepended
    # alongside the patched +serialize+, rather than as a +class_attribute+
    # inside an +ActiveSupport.on_load(:active_record)+ block. Hooks run in
    # registration order, so a gem required before Globalize can define models
    # -- and therefore call +serialize+ -- from its own hook, reaching the
    # patched +serialize+ before Globalize's hook has run. That raised
    # "NameError: undefined local variable or method
    # `globalize_serialized_attributes'". Defining them next to the patch makes
    # it impossible for one to exist without the other.
    module SerializedAttributes
      def globalize_serialized_attributes
        @globalize_serialized_attributes ||=
          if superclass.respond_to?(:globalize_serialized_attributes)
            superclass.globalize_serialized_attributes.dup
          else
            {}
          end
      end

      attr_writer :globalize_serialized_attributes
    end
  end
end

ActiveRecord::AttributeMethods::Serialization::ClassMethods.send(:prepend, Globalize::AttributeMethods::SerializedAttributes)

if ::ActiveRecord.version < Gem::Version.new("7.1.0")
  require_relative 'rails6_1/serialization'
elsif ::ActiveRecord.version < Gem::Version.new("7.2.0")
  require_relative 'rails7_1/serialization'
else
  require_relative 'rails7_2/serialization'
end
