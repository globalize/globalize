class MigratedBigint < ActiveRecord::Base
  self.primary_key = 'id'
  translates :name
end
