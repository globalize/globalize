  source "https://rubygems.org"

gemspec

gem "pry"

eval File.read(File.expand_path("../gemfiles/.gemfile.database-config.rb", __FILE__))

platforms :jruby do
  if !ENV['TRAVIS'] || ENV['DB'] == 'sqlite3'
    gem 'activerecord-jdbcsqlite3-adapter', github: "jruby/activerecord-jdbc-adapter"
  end

  if !ENV['TRAVIS'] || ENV['DB'] == 'mysql'
    gem 'activerecord-jdbcmysql-adapter', github: "jruby/activerecord-jdbc-adapter"
  end

  if !ENV['TRAVIS'] || %w(postgres postgresql).include?(ENV['DB'])
    gem 'activerecord-jdbcpostgresql-adapter', github: "jruby/activerecord-jdbc-adapter"
  end
end
