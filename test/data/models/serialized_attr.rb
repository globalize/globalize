class SerializedAttr < ActiveRecord::Base
  serialize :meta
  translates :meta
end

class JSONSerializedAttr < SerializedAttr
  serialize :meta, JSON
  translates :meta
end

class UnserializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
end
