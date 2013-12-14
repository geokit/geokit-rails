# -*- encoding: utf-8 -*-
require File.expand_path("../lib/geokit-rails/version", __FILE__)

Gem::Specification.new do |spec|
  spec.name          = "geokit-rails"
  spec.version       = GeokitRails::VERSION
  spec.authors       = ["Michael Noack", "Andre Lewis", "Bill Eisenhauer", "Jeremy Lecour"]
  spec.email         = ["michael+geokit@noack.com.au", "andre@earthcode.com", "bill_eisenhauer@yahoo.com", "jeremy.lecour@gmail.com"]
  spec.summary       = "Integrate Geokit with Rails"
  spec.description   = "Official Geokit plugin for Rails/ActiveRecord. Provides location-based goodness for your Rails app. Requires the Geokit gem."
  spec.summary       = "Geokit helpers for rails apps."
  spec.homepage      = "http://github.com/geokit/geokit-rails"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_dependency 'rails', '>= 3.0'
  spec.add_dependency 'geokit', '~> 1.5'
  spec.add_development_dependency "bundler", "> 1.0"
  spec.add_development_dependency "simplecov"
  spec.add_development_dependency "simplecov-rcov"
  spec.add_development_dependency 'rake'
  spec.add_development_dependency "mocha", "~> 0.9"
  spec.add_development_dependency 'coveralls'
  spec.add_development_dependency "mysql", "~> 2.8"
  spec.add_development_dependency "mysql2", "~> 0.2"
  spec.add_development_dependency "activerecord-mysql2spatial-adapter"
  spec.add_development_dependency "pg", "~> 0.10"
  spec.add_development_dependency "sqlite3"
end
