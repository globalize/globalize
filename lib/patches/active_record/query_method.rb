if ::ActiveRecord::VERSION::STRING < "5.0.0"
  require_relative 'rails4/query_method'
end