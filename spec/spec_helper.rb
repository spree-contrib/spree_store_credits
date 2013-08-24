# Configure Rails Environment
ENV["RAILS_ENV"] = "test"
require 'simplecov' if ENV["COVERAGE"]

require File.expand_path("../dummy/config/environment.rb",  __FILE__)

require 'rspec/rails'
require 'factory_girl'
require 'spree/testing_support/url_helpers'
require 'database_cleaner'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), "support/**/*.rb")].each {|f| require f }

# Requires factories defined in spree_core
require 'spree/testing_support/factories'

# include local factories
Dir["#{File.dirname(__FILE__)}/factories/**/*.rb"].each { |f| require File.expand_path(f)}

require 'spree/testing_support/controller_requests'
require 'spree/testing_support/authorization_helpers'

require 'ffaker'

RSpec.configure do |config|
  config.color = true
  config.mock_with :rspec

  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, comment the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = false
  config.before(:each) do
    if example.metadata[:js]
      DatabaseCleaner.strategy = :truncation
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

  config.include FactoryGirl::Syntax::Methods
  config.include Spree::TestingSupport::UrlHelpers
  config.include Spree::TestingSupport::ControllerRequests, :type => :controller
  config.include Rack::Test::Methods, :type => :feature
  config.include Capybara::DSL
end
