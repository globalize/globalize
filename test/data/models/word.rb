class Word < ActiveRecord::Base
  globalize :term, :definition
end
