# Database Configuration
if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
  gem 'sqlite3', platforms: [:ruby, :rbx]
end

if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
  group :mysql do
    gem 'mysql2', platforms: [:ruby, :rbx]
  end
end

if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
  group :postgres, :postgresql do
    gem 'pg', platforms: [:ruby, :rbx]
  end
end
