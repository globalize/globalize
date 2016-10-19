  source "https://rubygems.org"

gemspec

gem "pry"

eval File.read(File.expand_path("../gemfiles/.gemfile.database-config.rb", __FILE__))

platforms :rbx do
  gem "rubysl", "~> 2.0"
  gem "rubinius-developer_tools"
end

platforms :jruby do
  if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
    gem 'activerecord-jdbcsqlite3-adapter', git: "https://github.com/jruby/activerecord-jdbc-adapter"
  end

  if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
    gem 'activerecord-jdbcmysql-adapter', git: "https://github.com/jruby/activerecord-jdbc-adapter"
  end

  if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
    gem 'activerecord-jdbcpostgresql-adapter', git: "https://github.com/jruby/activerecord-jdbc-adapter"
  end
end
