class SerializedHash < ActiveRecord::Base
  serialize :meta, type: Hash
  translates :meta
end
