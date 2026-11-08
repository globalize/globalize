source 'https://rubygems.org'

gemspec

# Database Configuration
if !ENV['CI'] || ENV['DB'] == 'sqlite3'
  gem 'sqlite3', platforms: [:ruby, :rbx]
end

# have a look at test/support/database.yml which environment variables can be set
if !ENV['CI'] || ENV['DB'] == 'mysql'
  group :mysql do
    gem 'mysql2', platforms: [:ruby, :rbx]
  end
end

# Test with different ActiveRecord versions
# $ AR=7.1.5 bundle update; rake db:reset db:migrate test
# $ AR=7.2.2 bundle update; rake db:reset db:migrate test
if ENV['AR']
  gem 'activerecord', ENV['AR']
end

if !ENV['CI'] || %w(postgres postgresql).include?(ENV['DB'])
  group :postgres, :postgresql do
    gem 'pg', platforms: [:ruby, :rbx]
  end
end
