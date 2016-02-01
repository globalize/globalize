if ::ActiveRecord::VERSION::STRING < "5.0.0"
  require_relative 'rails4/uniqueness_validator'
else
  require_relative 'rails5/uniqueness_validator'
end