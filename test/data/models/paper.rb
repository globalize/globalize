require 'paper_trail'

class Paper < ActiveRecord::Base
  translates :description, :versioning => true
  has_paper_trail :only => [:name]

end
