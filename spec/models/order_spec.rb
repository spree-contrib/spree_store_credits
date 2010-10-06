require 'spec_helper'

describe Order do
  let(:order) { Order.new }

  context "Store credits." do
    before do
      reg_user = User.create(:email => "spree@example.com", :password => 'changeme2', :password_confirmation => 'changeme2')
      reg_user.store_credits << StoreCredit.new(:amount => 50, :remaining_amount => 50, :reason => 'gift')
      order.user = reg_user
      line_item = LineItem.new(:quantity => 1)
      line_item.variant = Variant.new(:price => 19.99, :product => Product.new(:name => "Product"))
      line_item.price = 19.99
      order.line_items << line_item
      order.send :update_totals
      order.save
    end
    
    it "Order#store_credit_amount should support mass-assignment" do
      order.update_attributes(:store_credit_amount => 5.0)
      order.store_credit_amount.should == 5.0
    end

    it "Order#store_credit_amount should be editable" do
      order.update_attributes(:store_credit_amount => 5.0)
      order.store_credit_amount.should == 5.0
      order.update_attributes(:store_credit_amount => 9.0)
      order.store_credit_amount.should == 9.0
      order.update_attributes(:store_credit_amount => 4.0)
      order.store_credit_amount.should == 4.0
    end

    it "Maximum store credit amount should be equals to order total" do
      order_total = order.total
      order.store_credit_amount = order_total + 5
      order.save
      order.store_credit_amount.should == order_total
    end
    
    it "Order#remove_store_credits should remove store credits from order" do
      order.update_attributes(:store_credit_amount => 5.0)
      order.store_credit_amount.should == 5.0
      order.update_attributes(:remove_store_credits => '1')
      order.store_credit_amount.should == 0.0
    end

  end
end
