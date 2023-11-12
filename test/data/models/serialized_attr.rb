class SerializedAttr < ActiveRecord::Base
  serialize :meta
  translates :meta
end

class ArraySerializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
  serialize :meta, :coder => JSON, :type => Array
  translates :meta
end

class JSONSerializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
  serialize :meta, :coder => JSON
  translates :meta
end

class UnserializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
end
