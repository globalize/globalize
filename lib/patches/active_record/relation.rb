module Globalize
  module Relation
    def where_values_hash(relation_table_name = table_name)
      return super unless respond_to?(:translations_table_name)
      super.merge(super(translations_table_name))
    end
  end
end

ActiveRecord::Relation.prepend Globalize::Relation