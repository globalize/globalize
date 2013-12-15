require 'paper_trail'

class Paper < ActiveRecord::Base
  has_paper_trail :only => [:name]
  translates :description, :versioning => true

end
