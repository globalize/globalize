class NewsItem < ActiveRecord::Base
  globalize :title, :foreign_key => :news_id
  self.table_name = :news
end
