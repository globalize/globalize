class Media < ActiveRecord::Base
  self.table_name = "medias"
  translates :title
end
