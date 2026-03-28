class StrippedStringType < ActiveRecord::Type::String
  def cast(value)
    value.is_a?(String) ? value.strip : super
  end
end

class TypedPost < ActiveRecord::Base
  attribute :title, StrippedStringType.new
  translates :title
end

class ReverseTypedPost < ActiveRecord::Base
  self.table_name = "typed_posts"

  translates :title
  attribute :title, StrippedStringType.new
end
