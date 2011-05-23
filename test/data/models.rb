# this little innocent class here makes 0.0.9 test fail
class Translation < ActiveRecord::Base
end

class Post < ActiveRecord::Base
  translates :title, :content, :published, :published_at, :versioning => true
  validates_presence_of :title
  scope :with_some_title, :conditions => { :title => 'some_title' }
end

class PostTranslation < ActiveRecord::Base
  def existing_method ; end
end

class ReloadingPost < Post
  after_create { reload }
end

class Blog < ActiveRecord::Base
  has_many :posts, :order => 'id ASC'
end


class Validatee < ActiveRecord::Base
  translates :string
end


class Parent < ActiveRecord::Base
  translates :content
end

class Child < Parent
end

class Comment < ActiveRecord::Base
  validates_presence_of :content
  belongs_to :post
end

class TranslatedComment < Comment
  translates :content
end

class User < ActiveRecord::Base
  translates :name
  validates_presence_of :name, :email
end

class Migrated < ActiveRecord::Base
  translates :name
end

class MigratedWithUltraLongModelName < ActiveRecord::Base
  translates :name
end

class UppercaseTableName < ActiveRecord::Base
  set_table_name "UPPERCASE_TABLE_NAME"
  translates :name
end

class Untranslated < ActiveRecord::Base
end
