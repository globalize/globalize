# Activate the gem you are reporting the issue against.
gem 'activerecord', '4.2.0'
gem 'globalize', '5.0.1'
require 'active_record'
require 'globalize'
require 'minitest/autorun'
require 'logger'

# Ensure backward compatibility with Minitest 4
Minitest::Test = MiniTest::Unit::TestCase unless defined?(Minitest::Test)

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table :posts, force: true do |t|
  end

  create_table :post_translations, force: true do |t|
    t.references :post
    t.string     :title
    t.text       :content
    t.string     :locale
  end
end

class Post < ActiveRecord::Base
  translates :content, :title
end

class BugTest < Minitest::Test
  def test_association_stuff
    post = Post.create!(title: 'HI')

    assert_equal 'HI', post.title
  end
end
