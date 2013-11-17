class Post < ActiveRecord::Base
  globalize :title, :content, :published, :published_at, :versioning => true
  validates_presence_of :title
  scope :with_some_title, proc { { :conditions => { :title => 'some_title' } } }
  accepts_nested_attributes_for :translations
end
