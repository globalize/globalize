class SerializedHash < ActiveRecord::Base
  serialize :meta, Hash
  globalize :meta
end
