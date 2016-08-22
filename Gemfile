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
    gem 'activerecord-jdbcsqlite3-adapter',
      github: "Paxa/activerecord-jdbc-adapter", branch: "rails-5"
  end

  if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
    gem 'activerecord-jdbcmysql-adapter',
      github: "Paxa/activerecord-jdbc-adapter", branch: "rails-5"
  end

  if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
    gem 'activerecord-jdbcpostgresql-adapter',
      github: "Paxa/activerecord-jdbc-adapter", branch: "rails-5"
  end
end
