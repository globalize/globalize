source 'https://rubygems.org'

gemspec path: '../'

gem 'activemodel', [">= 4.2.6", "< 5.0"]
gem 'activerecord', [">= 4.2.6", "< 5.0"]

group :development, :test do
  gem 'pry'

  platforms :jruby do
    gem 'activerecord-jdbcmysql-adapter', '~> 1.3.14'
    gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.14'
  end

  platforms :ruby, :rbx do
    gem 'sqlite3'
    gem 'mysql2'
    gem 'pg'
  end

  platforms :rbx do
    gem 'rubysl', '~> 2.0'
    gem 'rubinius-developer_tools'
  end
end
