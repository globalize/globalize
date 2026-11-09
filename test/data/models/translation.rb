# A top-level model named Translation clashes with the Translation class
# that Globalize defines inside each translated model.
class Translation < ActiveRecord::Base
  translates :value
end
