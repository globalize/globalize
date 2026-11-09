module Globalize
  module Attributes
    # Records the types declared with `attribute` so that `translates` can give
    # them to the translation class, which reads and writes translated values.
    def attribute(name, *args, **options, &block)
      super

      type = args.first
      # A plain Value doesn't cast, so it would only replace the column type.
      return if type.nil? || type.instance_of?(::ActiveRecord::Type::Value)

      name = name.to_sym
      type_options = options.except(:default)
      self.globalize_attribute_types = globalize_attribute_types.merge(name => [type, type_options])

      translation_class.attribute(name, type, **type_options) if translates? && translated?(name)
    end
  end
end
