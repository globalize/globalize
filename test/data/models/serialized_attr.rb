class SerializedAttr < ActiveRecord::Base
  serialize :meta
  translates :meta
end

class ArraySerializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
  serialize :meta, Array
  translates :meta
end

class JSONSerializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
  serialize :meta, JSON
  translates :meta
end

class UnserializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
end
