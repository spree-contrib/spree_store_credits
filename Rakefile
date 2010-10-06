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
  s.add_dependency 'spree_auth', ['>= 0.30.0.beta1']
  s.has_rdoc = false
  #s.extra_rdoc_files = [ "README.rdoc"]
  #s.rdoc_options = ["--main", "README.rdoc", "--inline-source", "--line-numbers"]
  #s.test_files = Dir['test/**/*.{yml,rb}']
end
Jeweler::GemcutterTasks.new

desc "Default Task"
task :default => [ :spec ]

require 'rspec'
require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new

require 'cucumber/rake/task'
Cucumber::Rake::Task.new do |t|
  t.cucumber_opts = %w{--format pretty}
end

desc "Regenerates a rails 3 app for testing"
task :test_app do
  SPREE_PATH = ENV['SPREE_PATH']
  raise "SPREE_PATH should be specified" unless SPREE_PATH
  require File.join(SPREE_PATH, 'lib/generators/spree/test_app_generator')
  class AuthTestAppGenerator < Spree::Generators::TestAppGenerator
    def tweak_gemfile
      append_file 'Gemfile' do
<<-gems
        gem 'spree_core', :path => '#{File.join(SPREE_PATH, 'core')}'
        gem 'spree_auth', :path => '#{File.join(SPREE_PATH, 'auth')}'
        gem 'spree_store_credits', :path => '../..'
gems
      end
    end

    def install_gems
      generate 'spree_core:install -f'
      generate 'spree_auth:install -f'
      generate 'spree_store_credits:install -f'
    end

    def migrate_db
      run_migrations
    end
  end
  AuthTestAppGenerator.start
end

namespace :test_app do
  desc 'Rebuild test and cucumber databases'
  task :rebuild_dbs do
    system("cd spec/test_app && rake db:drop db:migrate RAILS_ENV=test && rake db:drop db:migrate RAILS_ENV=cucumber")
  end
end
