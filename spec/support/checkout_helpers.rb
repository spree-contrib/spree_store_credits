def add_mug_to_cart
  visit spree.root_path
  click_link mug.name
  click_button "add-to-cart-button"
end

def setup_new_user_and_sign_up(email)
  create(:promotion_for_store_credits, :event_name => "spree.user.signup", :created_at => 2.days.ago)
  lambda {
    visit spree.signup_path

    fill_in "Email", :with => email
    fill_in "Password", :with => "qwerty"
    fill_in "Password Confirmation", :with => "qwerty"
    click_button "Create"
    add_mug_to_cart
  }.should change(Spree::StoreCredit, :count).by(1)
end

def fill_in_address
  address = "order_bill_address_attributes"
  fill_in "#{address}_firstname", :with => "Ryan"
  fill_in "#{address}_lastname", :with => "Bigg"
  fill_in "#{address}_address1", :with => "143 Swan Street"
  fill_in "#{address}_city", :with => "Richmond"
  select "United States of America", :from => "#{address}_country_id"
  select "Alabama", :from => "#{address}_state_id"
  fill_in "#{address}_zipcode", :with => "12345"
  fill_in "#{address}_phone", :with => "(555) 555-5555"
end