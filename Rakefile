require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require File.join(File.dirname(__FILE__), 'lib', 'globalize', 'version')

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
  rdoc.title    = 'Globalize3'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "globalize3"
    gemspec.version = Globalize::VERSION
    gemspec.summary = "Rails I18n: de-facto standard library for ActiveRecord 3 model/data translation"
    gemspec.description = "Rails I18n: de-facto standard library for ActiveRecord 3 model/data translation"
    gemspec.email = 'nobody@globalize-rails.org'
    gemspec.homepage = "http://github.com/svenfuchs/globlize3"
    gemspec.authors = ['Sven Fuchs', 'Joshua Harvey', 'Clemens Kofler', 'John-Paul Bader', 'Igor Galeta']
    gemspec.files = FileList["[A-Z]*", "{lib}/**/*", "{test}/**/*"]
    gemspec.rubyforge_project = "[none]"
    
    gemspec.add_dependency 'activerecord', '>= 3.0.0'
    gemspec.add_dependency 'activemodel', '>= 3.0.0'

    gemspec.add_development_dependency 'database_cleaner'
    gemspec.add_development_dependency 'mocha'
    gemspec.add_development_dependency 'pathname_local'
    gemspec.add_development_dependency 'test_declarative'
    gemspec.add_development_dependency 'ruby-debug'
    gemspec.add_development_dependency 'sqlite3-ruby'
  end
  
  Jeweler::GemcutterTasks.new
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
