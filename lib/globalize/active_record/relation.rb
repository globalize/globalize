module Globalize
  module ActiveRecord
    class Relation < ::ActiveRecord::Relation

      if ::ActiveRecord::VERSION::STRING >= "3.2.1"
        def where_values_hash
          equalities = with_default_scope.where_values.grep(Arel::Nodes::Equality).find_all { |node|
            node.left.relation.name == translations_table_name
          }

          super.merge(Hash[equalities.map { |where| [where.left.name, where.right] }]).with_indifferent_access
        end
      end
    end
  end
end
