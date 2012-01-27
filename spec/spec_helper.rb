# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'factory_girl'
require 'spree/url_helpers'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f }

# include local factories
Dir["#{File.dirname(__FILE__)}/factories/**/*.rb"].each { |f| require File.expand_path(f)}

# Requires factories defined in spree_core
require 'spree/core/testing_support/factories'

RSpec.configure do |config|
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation, { :except => ['spree_countries', 'spree_zones', 'spree_zone_members', 'spree_states', 'spree_roles'] }
    else
      DatabaseCleaner.strategy = :transaction
    end
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

  config.include Spree::UrlHelpers
  config.include Devise::TestHelpers, :type => :controller
  config.include Rack::Test::Methods, :type => :requests
end
