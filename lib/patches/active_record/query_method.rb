if ::ActiveRecord.version < Gem::Version.new("5.0.0")
  require_relative 'rails4/query_method'
end
