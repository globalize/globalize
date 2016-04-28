if ::ActiveRecord::VERSION::STRING >= "5.0.0"
  module Globalize
    module ConnectionAdapters
      module Quoting

        private

        def _quote(value)
          case value
            when Array      then
              "'#{quote_string(YAML.dump(value))}'"
            else
              super
          end
        end
      end
    end
  end

  ActiveRecord::ConnectionAdapters::AbstractAdapter.include Globalize::ConnectionAdapters::Quoting
end
