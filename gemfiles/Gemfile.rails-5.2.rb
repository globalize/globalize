source "https://rubygems.org"

gemspec path: "../"

gem "activemodel", [">= 5.2", "< 5.3"]
gem "activerecord", [">= 5.2", "< 5.3"]

gem "pry"

eval File.read(File.expand_path("../.gemfile.database-config.rb", __FILE__))

platforms :rbx do
  gem "rubysl", "~> 2.0"
  gem "rubinius-developer_tools"
end

platforms :jruby do
  if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
    gem 'activerecord-jdbcsqlite3-adapter', '~> 1'
  end

  if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
    gem 'activerecord-jdbcmysql-adapter', '~> 1'
  end

  if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
    gem 'activerecord-jdbcpostgresql-adapter', '~> 1'
  end
end
