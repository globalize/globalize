class User < ActiveRecord::Base
  globalize :name
  validates_presence_of :name, :email
end
