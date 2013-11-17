class SerializedAttr < ActiveRecord::Base
  serialize :meta
  globalize :meta
end
