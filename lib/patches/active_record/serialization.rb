if ::ActiveRecord.version < Gem::Version.new("5.1.0")
  require_relative 'rails4/serialization'
elsif ::ActiveRecord.version < Gem::Version.new("6.1.0")
  require_relative 'rails5_1/serialization'
elsif ::ActiveRecord.version < Gem::Version.new("7.1.0")
  require_relative 'rails6_1/serialization'
else
  require_relative 'rails7_1/serialization'
end
