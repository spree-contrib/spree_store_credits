# encoding: utf-8
require 'rubygems'
begin
  require 'jeweler'
rescue LoadError
  puts "Jeweler not available. Install it with: sudo gem install jeweler"
  exit 1
end
#gem 'rdoc', '= 2.2'
#require 'rdoc'
require 'rake'
require 'rake/testtask'
#require 'rake/rdoctask'
require 'rake/packagetask'
require 'rake/gempackagetask'

Jeweler::Tasks.new do |s|
  s.name = "spree_store_credits"
  s.summary = "Provides store credits for a Spree store."
  s.description = s.summary
  s.email = "roman@railsdog.com"
  s.homepage = "http://github.com/spree/spree-store-credits"
  s.authors = ["Roman Smirnov"]
  s.add_dependency 'spree_core', ['>= 0.30.0.beta1']
  s.has_rdoc = false
  #s.extra_rdoc_files = [ "README.rdoc"]
  #s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
  #s.test_files = Dir['test/**/*.{yml,rb}']
end
Jeweler::GemcutterTasks.new
