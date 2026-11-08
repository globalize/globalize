class SerializedHash < ActiveRecord::Base
  if Globalize.rails_7_2?
    serialize :meta, type: Hash
  else
    serialize :meta, Hash
  end
  translates :meta
end
