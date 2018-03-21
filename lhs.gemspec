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

  s.requirements << 'Ruby >= 2.3.0'
  s.required_ruby_version = '>= 2.3.0'

  s.add_dependency 'lhc', '~> 9.1.1'
  s.add_dependency 'activesupport', '> 4.2'
  s.add_dependency 'activemodel'

  s.add_development_dependency 'rspec-rails', '>= 3.7.0'
  s.add_development_dependency 'rails', '>= 4.0.0'
  s.add_development_dependency 'webmock'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'pry-byebug'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'rubocop', '~> 0.47.0'
  s.add_development_dependency 'json', '>=  1.8.2'

  s.license = 'GPL-3'
end
