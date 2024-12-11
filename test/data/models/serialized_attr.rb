class SerializedAttr < ActiveRecord::Base
  serialize :meta
  translates :meta
end

class ArraySerializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
  if Globalize.rails_7_2?
    serialize :meta, type: Array
  else
    serialize :meta, Array
  end
  translates :meta
end

class JSONSerializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
  if Globalize.rails_7_2?
    serialize :meta, coder: JSON
  else
    serialize :meta, JSON
  end
  translates :meta
end

class UnserializedAttr < ActiveRecord::Base
  self.table_name = 'serialized_attrs'
end
