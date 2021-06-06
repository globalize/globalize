if ::ActiveRecord.version >= Gem::Version.new("5.0.0")
  module Globalize
    module Relation
      def where_values_hash(relation_table_name = table_name)
        return super unless respond_to?(:translations_table_name)
        super.merge(super(translations_table_name))
      end

      if ::ActiveRecord.version >= Gem::Version.new("6.1.3")
        def scope_for_create
          return super unless respond_to?(:translations_table_name)
          super.merge(where_values_hash(translations_table_name))
        end
      end
    end
  end

  ActiveRecord::Relation.prepend Globalize::Relation
end
