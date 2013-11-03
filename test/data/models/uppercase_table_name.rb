class UppercaseTableName < ActiveRecord::Base
  self.table_name = "UPPERCASE_TABLE_NAME"
  globalize :name
end
