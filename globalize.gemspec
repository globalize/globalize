require File.expand_path('../lib/globalize/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'globalize'
  s.version      = Globalize::Version
  s.authors      = ['Sven Fuchs', 'Joshua Harvey', 'Clemens Kofler', 'John-Paul Bader', 'Tomasz Stachewicz', 'Philip Arndt', 'Chris Salzberg']
  s.email        = 'nobody@globalize-rails.org'
  s.homepage     = 'https://github.com/globalize/globalize'
  s.summary      = 'Rails I18n de-facto standard library for ActiveRecord model/data translation'
  s.description  = "#{s.summary}."
  s.license      = "MIT"

  s.files        = Dir['{lib/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'

  if ENV['RAILS_3_0']
    s.add_dependency 'activerecord', '~> 3.0.0'
    s.add_dependency 'activemodel', '~> 3.0.0'
  elsif ENV['RAILS_3_1']
    s.add_dependency 'activerecord', '~> 3.1.0'
    s.add_dependency 'activemodel', '~> 3.1.0'
  elsif ENV['RAILS_3_2']
    s.add_dependency 'activerecord', '~> 3.2.0'
    s.add_dependency 'activemodel', '~> 3.2.0'
  else
    # normal case
    s.add_dependency 'activerecord', '>= 3.0.0'
    s.add_dependency 'activemodel', '>= 3.0.0'
  end
  s.add_dependency 'paper_trail',  '~> 2'

  s.add_development_dependency 'database_cleaner', '~> 0.6.0'
  s.add_development_dependency 'mocha'
  s.add_development_dependency 'pathname_local'
  s.add_development_dependency 'test_declarative'
  s.add_development_dependency 'friendly_id'

  s.add_development_dependency 'sqlite3'
end
