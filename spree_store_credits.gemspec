# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY

  s.name        = 'spree_store_credits'
  s.version     = '1.0.0'
  s.authors     = ["Roman Smirnov", "Brian Quinn"]
  s.email       = 'roman@railsdog.com'
  s.homepage    = 'http://github.com/spree/spree-store-credits'
  s.summary     = 'Provides store credits for a Spree store.'
  s.description = 'Provides store credits for a Spree store.'
  s.required_ruby_version = '>= 1.8.7'
  s.rubygems_version      = '1.3.6'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_paths = ["lib"]

  s.add_dependency('spree_core',  '>= 0.30.1')
end

