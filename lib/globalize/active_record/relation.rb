module Globalize
  module ActiveRecord
    class Relation < ::ActiveRecord::Relation

      attr_accessor :translations_reload_needed

      class WhereChain < ::ActiveRecord::QueryMethods::WhereChain
        def not(opts, *rest)
          if parsed = @scope.parse_translated_conditions(opts)
            @scope.translations_reload_needed = true
            @scope.with_translations_in_fallbacks.where.not(parsed, *rest)
          else
            super
          end
        end
      end

      def where(opts = :chain, *rest)
        if opts == :chain
          WhereChain.new(spawn)
        elsif parsed = parse_translated_conditions(opts)
          self.translations_reload_needed = true
          super(parsed, *rest).with_translations_in_fallbacks
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

      %w[ first last take ].each do |method_name|
        eval <<-END_RUBY
          def #{method_name}
            super.tap do |f|
              if f && translations_reload_needed
                f.translations.reload
                translations_reload_needed = false
              end
            end
          end
        END_RUBY
      end

      def with_translations_in_fallbacks
        with_translations(Globalize.fallbacks)
      end

      def parse_translated_conditions(opts)
        if opts.is_a?(Hash) && (keys = opts.symbolize_keys.keys & translated_attribute_names).present?
          opts = opts.dup
          keys.each { |key| opts[translated_column_name(key)] = opts.delete(key) || opts.delete(key.to_s) }
          opts
        end
      end

      def where_values_hash
        values_hash = where_equalities.reduce({}) do |hash, where|
          name = where.left.name
          hash[name] = where_bind_values.fetch(name.to_s) { where.right }
          hash
        end

        super.merge values_hash
      end

      protected
      def where_equalities
        with_default_scope.where_values.grep(Arel::Nodes::Equality).select do |node|
          node.left.relation.name == translations_table_name
        end
      end

      def where_bind_values
        bind_values.select(&:first).reduce({}) do |hash, (column, value)|
          hash[column.name] = value
          hash
        end
      end
    end
  end
end
