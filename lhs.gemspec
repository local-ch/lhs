$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "lhs/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "lhs"
  s.version     = LHS::VERSION
  s.authors     = ['local.ch']
  s.email       = ['ws-operations@local.ch']
  s.homepage    = 'https://github.com/local-ch/lhs'
  s.summary     = 'LocalHttpServices'
  s.description = 'Rails gem providing an easy interface to use http services here at local'

  s.files        = `git ls-files`.split("\n")
  s.test_files   = `git ls-files -- spec/*`.split("\n")
  s.require_paths = ['lib']

  s.requirements << 'Ruby >= 1.9.2'
  s.required_ruby_version = '~> 1.9.2'

  s.add_dependency 'lhc', '~> 0.1.2'
  s.add_dependency 'lhc-core-interceptors', '~> 0.0.3'
end
