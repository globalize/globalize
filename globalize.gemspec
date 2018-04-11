require File.expand_path('../lib/globalize/version', __FILE__)

Gem::Specification.new do |s|
  s.name         = 'globalize'
  s.version      = Globalize::Version
  s.authors      = ['Sven Fuchs', 'Joshua Harvey', 'Clemens Kofler', 'John-Paul Bader', 'Tomasz Stachewicz', 'Philip Arndt', 'Chris Salzberg']
  s.email        = 'nobody@globalize-rails.org'
  s.homepage     = 'http://github.com/globalize/globalize'
  s.summary      = 'Rails I18n de-facto standard library for ActiveRecord model/data translation'
  s.description  = "#{s.summary}."
  s.license      = "MIT"

  s.files        = Dir['{lib/**/*,[A-Z]*}']
  s.platform     = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.rubyforge_project = '[none]'
  s.required_ruby_version = '>= 2.0.0'

  s.add_dependency 'activerecord', '>= 4.2', '< 5.3'
  s.add_dependency 'activemodel', '>= 4.2', '< 5.3'
  s.add_dependency 'request_store', '~> 1.0'

  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'rdoc'
  s.add_development_dependency 'rake'
end
