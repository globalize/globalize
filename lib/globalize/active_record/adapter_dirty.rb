module Globalize
  module ActiveRecord
    module AdapterDirty
      def write locale, name, value
        # Dirty tracking, paraphrased from
        # ActiveRecord::AttributeMethods::Dirty#write_attribute.
        name = name.to_s
        store_old_value name, locale
        old_values = dirty[name]
        old_value = old_values[locale]
        is_changed = record.send :attribute_changed?, name
        if is_changed && value == old_value
          # If there's already a change, delete it if this undoes the change.
          old_values.delete locale
          if old_values.empty?
            _reset_attribute name
          end
        elsif !is_changed
          # If there's not a change yet, record it.
          record.send(:attribute_will_change!, name) if old_value != value
        end

        super locale, name, value
      end

      attr_writer :dirty
      def dirty
        @dirty ||= {}
      end

      def store_old_value name, locale
        dirty[name] ||= {}
        unless dirty[name].key? locale
          old = fetch(locale, name)
          old = old.dup if old.duplicable?
          dirty[name][locale] = old
        end
      end

      def clear_dirty
        self.dirty = {}
      end

      def _reset_attribute name
        record.send(:clear_attribute_changes, [name])
      end

      def reset
        clear_dirty
        super
      end

      def changed_attributes(locale)
        Hash[changes(locale).map { |name, change| [name, change.first] }]
      end

      def changed
        stash.keys.flat_map { |locale| changes(locale).keys }.uniq
      end

      def changes(locale)
        stash[locale].keys.inject({}) do |hash, name|
          next hash unless dirty[name].is_a?(Hash)
          next hash unless dirty[name].key?(locale)

          new_value = stash[locale][name]
          old_value = dirty[name][locale]

          unless new_value == old_value
            hash[name] = [old_value, new_value]
          end

          hash
        end
      end

    end
  end
end
