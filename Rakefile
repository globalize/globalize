require 'rake'
require 'rake/testtask'
require 'rdoc/task'

desc 'Default: run unit tests.'
task :default => :test

desc 'Run all tests.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Globalize'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :load_path do
  %w(lib test).each do |path|
    $LOAD_PATH.unshift(File.expand_path("../#{path}", __FILE__))
  end
end

namespace :db do
  desc 'Create the database'
  task :create => :load_path do
    require 'support/database'

    Globalize::Test::Database.create!
  end

  desc "Drop the database"
  task :drop => :load_path do
    require 'support/database'

    Globalize::Test::Database.drop!
  end

  desc "Set up the database schema"
  task :migrate => :load_path do
    require 'support/database'

    Globalize::Test::Database.migrate!
    # ActiveRecord::Schema.migrate :up
  end

  desc "Drop and recreate the database schema"
  task :reset => [:drop, :create]
end
