$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lhs/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lhs"
  s.version     = LHS::VERSION
  s.authors     = ['https://github.com/local-ch/lhs/graphs/contributors']
  s.email       = ['ws-operations@local.ch']
  s.homepage    = 'https://github.com/local-ch/lhs'
  s.summary     = 'Rails gem providing an easy, active-record-like interface for http json services'
  s.description = s.summary

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 1.9.2'
  s.required_ruby_version = '>= 1.9.2'

  s.add_dependency 'lhc', '>= 3.5.2'
  s.add_dependency 'lhc-core-interceptors', '>= 2.0.1'

  s.add_development_dependency 'rspec-rails', '>= 3.0.0'
  s.add_development_dependency 'rails', '>= 4.0.0'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'geminabox'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'ciderizer'
  s.add_development_dependency 'capybara'
end
