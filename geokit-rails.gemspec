# -*- encoding: utf-8 -*-
require File.expand_path("../lib/geokit-rails/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "geokit-rails"
  s.version     = GeokitRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Noack", "Andre Lewis", "Bill Eisenhauer", "Jeremy Lecour"]
  s.email       = ["michael@noack.com.au", "andre@earthcode.com", "bill_eisenhauer@yahoo.com", "jeremy.lecour@gmail.com"]
  s.homepage    = "http://github.com/geokit/geokit-rails"
  s.summary     = "Integrate Geokit with Rails"
  s.description = "Official Geokit plugin for Rails/ActiveRecord. Provides location-based goodness for your Rails app. Requires the Geokit gem."

  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "test_gem"

  s.add_runtime_dependency 'rails', '>= 3.0'
  s.add_runtime_dependency 'geokit', '~> 1.5'

  s.add_development_dependency "bundler", "> 1.0"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov"
  s.add_development_dependency "mocha", "~> 0.9"
  s.add_development_dependency "mysql", "~> 2.8"
  s.add_development_dependency "mysql2", "~> 0.2"
  s.add_development_dependency "pg", "~> 0.10"
  s.add_development_dependency "sqlite3"

  s.files        = Dir.glob("lib/**/*.rb")
  s.test_files   = Dir.glob("test/**/*")
  s.require_path = "lib"
end
