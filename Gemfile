source 'https://rubygems.org'

gemspec

# Database Configuration
if !ENV['CI'] || ENV['DB'] == 'sqlite3'
  gem 'sqlite3', platforms: [:ruby, :rbx]
end

if !ENV['CI'] || ENV['DB'] == 'mysql'
  group :mysql do
    gem 'mysql2', platforms: [:ruby, :rbx]
  end
end

if !ENV['CI'] || %w(postgres postgresql).include?(ENV['DB'])
  group :postgres, :postgresql do
    gem 'pg', platforms: [:ruby, :rbx]
  end
end
