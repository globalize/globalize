require 'active_record/validations/uniqueness.rb'

module Globalize
  module Validations
    module UniquenessValidator
      def validate_each(record, attribute, value)
        klass = record.class
        if klass.translates? && klass.translated?(attribute)
          finder_class = klass.translation_class
          table = finder_class.arel_table
          relation = build_relation(finder_class, table, attribute, value).where(locale: Globalize.locale)
          relation = relation.where.not(klass.reflect_on_association(:translations).foreign_key => record.send(:id)) if record.persisted?
          # relation = relation.and(table[klass.reflect_on_association(:translations).foreign_key].not_eq(record.send(:id))) if record.persisted?

          translated_scopes = Array(options[:scope]) & klass.translated_attribute_names
          untranslated_scopes = Array(options[:scope]) - translated_scopes

          untranslated_scopes.each do |scope_item|
            scope_value = record.send(scope_item)
            reflection = klass.reflect_on_association(scope_item)
            if reflection
              scope_value = record.send(reflection.foreign_key)
              scope_item = reflection.foreign_key
            end
            relation = relation.where(find_finder_class_for(record).table_name => { scope_item => scope_value })
          end

          translated_scopes.each do |scope_item|
            scope_value = record.send(scope_item)
            relation = relation.where(scope_item => scope_value)
          end
          relation = relation.merge(options[:conditions]) if options[:conditions]

          # if klass.unscoped.with_translations.where(relation).exists?
          if relation.exists?
            record.errors.add(attribute, :taken, options.except(:case_sensitive, :scope).merge(:value => value))
          end
        else
          super(record, attribute, value)
        end
      end
    end
  end
end

ActiveRecord::Validations::UniquenessValidator.prepend Globalize::Validations::UniquenessValidator