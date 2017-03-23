module Globalize
  module ActiveRecord
    module QueryMethods
      class WhereChain < ::ActiveRecord::QueryMethods::WhereChain
        def not(opts, *rest)
          if parsed = @scope.clone.parse_translated_conditions(opts)
            @scope.join_translations.where.not(parsed, *rest)
          else
            super
          end
        end
      end

      def where(opts = :chain, *rest)
        if opts == :chain
          WhereChain.new(spawn)
        elsif parsed = parse_translated_conditions(opts)
          join_translations(super(parsed, *rest))
        else
          super
        end
      end

      def order(opts, *rest)
        if respond_to?(:translated_attribute_names) && parsed = parse_translated_order(opts)
          join_translations super(parsed)
        else
          super
        end
      end

      def exists?(conditions = :none)
        if parsed = parse_translated_conditions(conditions)
          with_translations_in_fallbacks.exists?(parsed)
        else
          super
        end
      end

      def with_translations_in_fallbacks
        with_translations(Globalize.fallbacks)
      end

      def parse_translated_conditions(opts)
        if opts.is_a?(Hash) && respond_to?(:translated_attribute_names) && (keys = opts.symbolize_keys.keys & translated_attribute_names).present?
          opts = opts.dup
          keys.each { |key| opts[translated_column_name(key)] = opts.delete(key) || opts.delete(key.to_s) }
          opts
        end
      end

      if ::ActiveRecord::VERSION::STRING < "5.0.0"
        def where_values_hash(*args)
          return super unless respond_to?(:translations_table_name)
          equalities = respond_to?(:with_default_scope) ? with_default_scope.where_values : where_values
          equalities = equalities.grep(Arel::Nodes::Equality).find_all { |node|
            node.left.relation.name == translations_table_name
          }

          binds = Hash[bind_values.find_all(&:first).map { |column, v| [column.name, v] }]

          super.merge(Hash[equalities.map { |where|
            name = where.left.name
            [name, binds.fetch(name.to_s) { right = where.right; right.is_a?(Arel::Nodes::Casted) ? right.val : right }]
          }])
        end
      end

      def join_translations(relation = self)
        if relation.joins_values.include?(:translations)
          relation
        else
          relation.with_translations_in_fallbacks
        end
      end

      private

      def arel_translated_order_node(column, direction)
        unless translated_column?(column)
          return self.arel_table[column].send(direction)
        end

        full_column = translated_column_name(column)

        # Inject `full_column` to the select values to avoid
        # PG::InvalidColumnReference errors with distinct queries on Postgres
        if select_values.empty?
          self.select_values = [self.arel_table[Arel.star], full_column]
        else
          self.select_values << full_column
        end

        translation_class.arel_table[column].send(direction)
      end

      def parse_translated_order(opts)
        case opts
        when Hash
          # Do not process nothing unless there is at least a translated column
          # so that the `order` statement will be processed by the original
          # ActiveRecord method
          return nil unless opts.find { |col, dir| translated_column?(col) }

          # Build order arel nodes for translateds and untranslateds statements
          ordering = opts.map do |column, direction|
            arel_translated_order_node(column, direction)
          end

          order(ordering).order_values
        when Symbol
          parse_translated_order({ opts => :asc })
        else # failsafe returns nothing
          nil
        end
      end

      def translated_column?(column)
        translated_attribute_names.include?(column)
      end
    end
  end
end
