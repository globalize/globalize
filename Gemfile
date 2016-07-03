source "https://rubygems.org"

gemspec

gem "pry"

eval File.read(File.expand_path("../gemfiles/.gemfile.database-config.rb", __FILE__))

platforms :rbx do
  gem "rubysl", "~> 2.0"
  gem "rubinius-developer_tools"
end
