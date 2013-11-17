class ModelWithCustomTableName < ActiveRecord::Base
  globalize :name, :table_name => :mctn_translations
end
