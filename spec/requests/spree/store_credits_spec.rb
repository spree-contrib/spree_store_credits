require 'spec_helper'

module Spree
  describe "Promotion for Store Credits" do

    context "#new user" do
      it "should give me a store credit when I register" do

        Factory(:promotion_for_store_credits, :event_name => "spree.user.signup")

        new_user = Factory.build(:user)

        post spree.user_registration_path, {"commit"=>"Create", "user"=> {"password" => new_user.password, "email" => new_user.email }}
        new_user = User.find_by_email new_user.email
        new_user.store_credits.size.should == 1
      end
    end
  end
end
