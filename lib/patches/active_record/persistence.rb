module Globalize
  module Persistence
    # Updates the associated record with values matching those of the instance attributes.
    # Returns the number of affected rows.
    def _update_record(attribute_names = self.attribute_names)
      attribute_names_without_translated = attribute_names.select{ |k| not respond_to?('translated?') or not translated?(k) }
      super(attribute_names_without_translated)
    end

    def _create_record(attribute_names = self.attribute_names)
      attribute_names_without_translated = attribute_names.select{ |k| not respond_to?('translated?') or not translated?(k) }
      super(attribute_names_without_translated)
    end
  end
end

ActiveRecord::Persistence.send(:prepend, Globalize::Persistence)