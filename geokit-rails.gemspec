# -*- encoding: utf-8 -*-
require File.expand_path("../lib/geokit-rails/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "geokit-rails"
  s.version     = GeokitRails::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Andre Lewis", "Bill Eisenhauer", "Jeremy Lecour"]
  s.email       = ["andre@earthcode.com", "bill_eisenhauer@yahoo.com", "jeremy.lecour@gmail.com"]
  s.homepage    = "http://rubygems.org/gems/test_gem"
  s.summary     = "Integrate Geokit with Rails 3"
  s.description = "Integrate Geokit with Rails 3"

  s.required_rubygems_version = ">= 1.3.6"
  # s.rubyforge_project         = "test_gem"

  s.add_runtime_dependency 'rails', '~> 3.0.0'
  s.add_runtime_dependency 'geokit', '~> 1.5.0'

  s.add_development_dependency "bundler", "~> 1.0.0"
  s.add_development_dependency "rcov", "~> 0.9.9"
  s.add_development_dependency "mocha", "~> 0.9.8"
  s.add_development_dependency "mysql", "~> 2.8.1"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
