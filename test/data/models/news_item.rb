class NewsItem < ActiveRecord::Base
  self.table_name = :news if Globalize::RAILS_4_2
  translates :title, :foreign_key => :news_id
  self.table_name = :news unless Globalize::RAILS_4_2
end
