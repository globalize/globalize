class TwoAttributesMigrated < ActiveRecord::Base
  globalize :name, :body
end
