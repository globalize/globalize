# Database Configuration
if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
  gem 'activerecord-jdbcsqlite3-adapter', github: "jruby/activerecord-jdbc-adapter", branch: "rails-5",
      platform: :jruby
  gem 'sqlite3', platforms: [:ruby, :rbx]
end

if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
  group :mysql do
    gem 'activerecord-jdbcmysql-adapter', github: "jruby/activerecord-jdbc-adapter", branch: "rails-5",
      platform: :jruby
    gem 'mysql2', platforms: [:ruby, :rbx]
  end
end

if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
  group :postgres, :postgresql do
    gem 'activerecord-jdbcpostgresql-adapter', github: "jruby/activerecord-jdbc-adapter", branch: "rails-5",
      platform: :jruby
    gem 'pg', platforms: [:ruby, :rbx]
  end
end
