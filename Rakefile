# encoding: utf-8
require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rubygems/package_task'

gemfile = File.expand_path('../spec/test_app/Gemfile', __FILE__)
if File.exists?(gemfile) && (%w(spec cucumber).include?(ARGV.first.to_s) || ARGV.size == 0)
  require 'bundler'
  ENV['BUNDLE_GEMFILE'] = gemfile
  Bundler.setup

  require 'rspec'
  require 'rspec/core/rake_task'
  RSpec::Core::RakeTask.new

  require 'cucumber/rake/task'
  Cucumber::Rake::Task.new do |t|
    t.cucumber_opts = %w{--format progress}
  end
end

desc "Default Task"
task :default => [:spec, :cucumber ]

spec = eval(File.read('spree_store_credits.gemspec'))

Gem::PackageTask.new(spec) do |p|
  p.gem_spec = spec
end

desc "Release to gemcutter"
task :release => :package do
  require 'rake/gemcutter'
  Rake::Gemcutter::Tasks.new(spec).define
  Rake::Task['gem:push'].invoke
end

desc "Default Task"
task :default => [ :spec ]

desc "Regenerates a rails 3 app for testing"
task :test_app do
  SPREE_PATH = ENV['SPREE_PATH']
  raise "SPREE_PATH should be specified" unless SPREE_PATH
  require File.join(SPREE_PATH, 'lib/generators/spree/test_app_generator')

  class SpreeStoreCreditTestAppGenerator < Spree::Generators::TestAppGenerator

    def install_gems
      inside "test_app" do
        run 'bundle exec rake spree_core:install'
        run 'bundle exec rake spree_auth:install'
        run 'bundle exec rake spree_promo:install'
        generate 'spree_store_credits:install -f'
      end
    end

    def migrate_db
      run_migrations
    end

    protected
    def full_path_for_local_gems
      <<-gems
gem 'spree_core', :path => \'#{File.join(SPREE_PATH, "core")}\'
gem 'spree_auth', :path => \'#{File.join(SPREE_PATH, "auth")}\'
gem 'spree_promo', :path => \'#{File.join(SPREE_PATH, "promo")}\'
gem 'spree_store_credits', :path => \'#{File.expand_path('..', __FILE__)}\'
      gems
    end

  end
  SpreeStoreCreditTestAppGenerator.start
end

namespace :test_app do
  desc 'Rebuild test and cucumber databases'
  task :rebuild_dbs do
    system("cd spec/test_app && bundle exec rake db:drop db:migrate RAILS_ENV=test && bundle exec rake db:drop db:migrate RAILS_ENV=cucumber")
  end
end
