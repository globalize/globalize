class MigratedWithMegaUltraSuperLongModelNameWithMoreThenSixtyCharacters < ActiveRecord::Base
  self.table_name = "migrateds"
  translates :name
end
