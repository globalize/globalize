source "https://rubygems.org"

gemspec path: "../"

gem "activemodel", [">= 4.2.6", "< 5.0"]
gem "activerecord", [">= 4.2.6", "< 5.0"]

gem "pry"

eval File.read(File.expand_path("../.gemfile.database-config.rb", __FILE__))

platforms :rbx do
  gem "rubysl", "~> 2.0"
  gem "rubinius-developer_tools"
end
