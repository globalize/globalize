# frozen_string_literal: true

require_relative 'lib/globalize/version'

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
  s.required_ruby_version = '>= 3.0'

  s.add_dependency 'activesupport', '>= 7.0', '< 8.1'
  s.add_dependency 'activerecord', '>= 7.0', '< 8.1'
  s.add_dependency 'activemodel', '>= 7.0', '< 8.1'
  s.add_dependency 'request_store', '~> 1.0'

  s.add_development_dependency 'appraisal'
  s.add_development_dependency 'database_cleaner'
  s.add_development_dependency 'm'
  s.add_development_dependency 'minitest'
  s.add_development_dependency 'minitest-reporters'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rdoc'
end
