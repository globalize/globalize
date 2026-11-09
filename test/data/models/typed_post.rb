class StrippedStringType < ActiveRecord::Type::String
  def cast(value)
    value.is_a?(String) ? value.strip : super
  end
end

class ReversedStringType < ActiveRecord::Type::String
  def serialize(value)
    value&.reverse
  end

  def deserialize(value)
    value&.reverse
  end
end

class TypedPost < ActiveRecord::Base
  attribute :title, StrippedStringType.new
  attribute :rating, :integer
  attribute :code, ReversedStringType.new
  translates :title, :rating, :code
end

class ReverseTypedPost < ActiveRecord::Base
  self.table_name = "typed_posts"

  translates :title, :rating, :code
  attribute :title, StrippedStringType.new
  attribute :rating, :integer
  attribute :code, ReversedStringType.new
end
