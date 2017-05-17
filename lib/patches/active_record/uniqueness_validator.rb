if ::ActiveRecord::VERSION::STRING < "5.0.0"
  require_relative 'rails4/uniqueness_validator'
elsif ::ActiveRecord::VERSION::STRING < "5.1.0"
  require_relative 'rails5/uniqueness_validator'
else
  require_relative 'rails5_1/uniqueness_validator'
end