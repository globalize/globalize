# Database Configuration
if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter', '~> 1.3.14', platform: :jruby
  gem 'sqlite3', platforms: [:ruby, :rbx]
end

if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
  group :mysql do
    gem 'activerecord-jdbcmysql-adapter', '~> 1.3.14', platform: :jruby
    gem 'mysql2', platforms: [:ruby, :rbx]
  end
end

if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
  group :postgres, :postgresql do
    gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.14', platform: :jruby
    gem 'pg', platforms: [:ruby, :rbx]
  end
end
