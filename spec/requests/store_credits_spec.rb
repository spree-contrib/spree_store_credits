require 'spec_helper'

describe "Promotion for Store Credits" do

  before(:all) do
    DatabaseCleaner.strategy = :truncation
    DatabaseCleaner.clean
  end

  before(:each) do
    DatabaseCleaner.start
  end

  after(:each) do
    DatabaseCleaner.clean
  end

  context "#new user" do
    it "should give me a store credit when I register" do

      Factory(:promotion_for_store_credits, :event_name => "spree.user.signup")

      new_user = Factory.build(:user)

      post user_registration_path, {"commit"=>"Create", "user"=> {"password" => new_user.password, "email" => new_user.email }}
      new_user = User.find_by_email new_user.email
      new_user.store_credits.size.should == 1
    end
  end
end
