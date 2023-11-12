class SerializedHash < ActiveRecord::Base
  serialize :meta, :coder  => JSON
  translates :meta
end
