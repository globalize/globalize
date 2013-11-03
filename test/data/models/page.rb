class Page < ActiveRecord::Base
  globalize :title
  globalize :body
end
