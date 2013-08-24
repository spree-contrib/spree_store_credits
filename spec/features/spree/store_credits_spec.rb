require 'spec_helper'

describe "Promotion for Store Credits" do
  let!(:country) { create(:country, :states_required => true) }
  let!(:state) { create(:state, :country => country) }
  let!(:shipping_method) { create(:shipping_method) }
  let!(:stock_location) { create(:stock_location) }
  let!(:mug) { create(:product, :name => "RoR Mug") }
  let!(:payment_method) { create(:payment_method) }
  let!(:zone) { create(:zone) }

  context "#new user" do
    let(:address) { create(:address, :state => Spree::State.first) }

    before do
      shipping_method.calculator.set_preference(:amount, 10)
    end

    it "should give me a store credit when I register", :js => true do
      email = 'paul@gmail.com'
      setup_new_user_and_sign_up(email)
      new_user = Spree.user_class.find_by_email email
      new_user.store_credits.size.should == 1
    end

    it "should not allow the user to apply the store credit if minimum order amount is not reached", :js => true do
      reset_spree_preferences do |config|
       config.use_store_credit_minimum = 100
      end
      email = 'george@gmail.com'
      setup_new_user_and_sign_up(email)

      # regression fix double giving store credits
      Spree.user_class.find_by_email(email).store_credits(true).count.should == 1
      click_button "Checkout"

      fill_in_address
      click_button "Save and Continue"
      click_button "Save and Continue"
      page.should have_content("You have $1,234.56 of store credits")
      fill_in "order_store_credit_amount", :with => "50"

      click_button "Save and Continue"
      page.should have_content("Order's item total is less than the minimum allowed ($100.00) to use store credit")

      reset_spree_preferences do |config|
        config.use_store_credit_minimum = 1
      end
      click_button "Save and Continue"
      # Store credits MAXIMUM => item_total - 0.01 in order to be valid ex : paypal orders
      page.should have_content("$-19.98")
      page.should have_content("Your order has been processed successfully")
      Spree::Order.count.should == 2 # 1 Purchased + 1 new empty cart order


      # store credits should be consumed
      visit spree.account_path
      page.should have_content("Current store credit: $1,214.58")

    end

    it "should allow if not using store credit and minimum order is not reached", :js => true do
      reset_spree_preferences do |config|
       config.use_store_credit_minimum = 100
      end

      email = 'patrick@gmail.com'
      setup_new_user_and_sign_up(email)

      Spree.user_class.find_by_email(email).store_credits(true).count.should == 1

      click_button "Checkout"

      fill_in_address
      click_button "Save and Continue"
      click_button "Save and Continue"
      fill_in "order_store_credit_amount", :with => "0"

      click_button "Save and Continue"
      page.should have_content("Your order has been processed successfully")
      Spree::Order.count.should == 2 # 1 Purchased + 1 new empty cart order

      # store credits should be unchanged
      visit spree.account_path
      page.should have_content("Current store credit: $1,234.56")
    end

    it "should allow using store credit if minimum order amount is reached", :js => true do
      reset_spree_preferences do |config|
        config.use_store_credit_minimum = 10
      end
      email = 'sam@gmail.com'
      setup_new_user_and_sign_up(email)
      Spree.user_class.find_by_email(email).store_credits(true).count.should == 1

      click_button "Checkout"

      fill_in_address
      click_button "Save and Continue"
      click_button "Save and Continue"

      fill_in "order_store_credit_amount", :with => "10"
      click_button "Save and Continue"

      page.should have_content("$-10.00")
      page.should have_content("Your order has been processed successfully")
      Spree::Order.count.should == 2 # 1 Purchased + 1 new empty cart order

      # store credits should be consumed
      visit spree.account_path
      page.should have_content("Current store credit: $1,224.56")
    end

    it "should allow even when admin is giving store credits", :js => true do
      sign_in_as! user = FactoryGirl.create(:admin_user)
      visit spree.new_admin_user_store_credit_path(user)
      fill_in "Amount", :with => 10
      fill_in "Reason", :with => "Gift"

      click_button "Create"

      reset_spree_preferences do |config|
        config.use_store_credit_minimum = 10
      end

      visit spree.product_path(mug)

      click_button "Add To Cart"
      click_button "Checkout"

      fill_in_address
      click_button "Save and Continue"
      click_button "Save and Continue"
      fill_in "order_store_credit_amount", :with => "10"

      click_button "Save and Continue"
      page.should have_content("$-10.00")
      page.should have_content("Your order has been processed successfully")

      # store credits should be consumed
      visit spree.account_path

      page.should_not have_content('Current store credit: $10.00')
      Spree::Order.count.should == 2 # 1 Purchased + 1 new empty cart order
    end

    after(:each) { reset_spree_preferences }
  end
end