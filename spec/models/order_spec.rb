require 'spec_helper'

describe Order do
  let(:user) { mock_model User, :email => 'spree@example.com', :store_credits_total => 45.00 }
  let(:line_item) { mock_model(LineItem, :variant => mock('variant'), :quantity => 5, :price => 10) }
  let(:order) { Order.create() }

  before { order.stub(:user => user, :total => 50 ) }

  context "process_store_credit" do
    it "should create store credit adjustment when user has sufficient credit" do
      order.store_credit_amount = 5.0
      order.save
      order.store_credits.size.should == 1
      order.store_credit_amount.should == 5.0
    end

    it "should only create adjustment with amount equal to users total credit" do
      order.store_credit_amount = 50.0
      order.save
      order.store_credit_amount.should == 45.00
    end

    it "should only create adjusment with amount equal to order total" do
      user.stub(:store_credits_total => 100.0)
      order.store_credit_amount = 90.0
      order.save
      order.store_credit_amount.should == 50.00
    end

    it "should not create adjustment when you does not have any credit" do
      user.stub(:store_credits_total => 0.0)
      order.store_credit_amount = 5.0
      order.save
      order.store_credits.size.should == 0
      order.store_credit_amount.should == 0.0
    end

    it "should update order totals if credit is applied" do
      order.should_receive(:update_totals)
      order.store_credit_amount = 5.0
      order.save
    end

    it "should update payment amount if credit is applied" do
      order.stub(:payment => mock('payment'))
      order.payment.should_receive(:amount=)
      order.store_credit_amount = 5.0
      order.save
    end

    it "should create negative adjustment" do
      order.store_credit_amount = 5.0
      order.save
      order.adjustments[0].amount.should == -5.0
    end

    context "with an existing adjustment" do
      before { order.adjustments.create(:source_type => "StoreCredit",  :label => I18n.t(:store_credit) , :amount => -10) }

      it "should decrement existing adjustment is specific amount is less than adjustment amount" do
        order.store_credit_amount = 5.0
        order.save
        order.store_credits.size.should == 1
        order.store_credit_amount.should == 5.0
      end

      it "should increase existing adjustment is specified amount is greater than adjustment amount" do
        order.store_credit_amount = 25.0
        order.save
        order.store_credits.size.should == 1
        order.store_credit_amount.should == 25.0
      end

      it "should destroy the adjustment if specified amount is zero" do
        order.store_credit_amount = 0.0
        order.save
        order.store_credits.size.should == 0
        order.store_credit_amount.should == 0.0
      end
    end

  end

  context "store_credit_amount" do
    it "should return total for all store credit adjustments applied to order" do
      order.adjustments.create(:source_type => "StoreCredit",  :label => I18n.t(:store_credit) , :amount => -10)
      order.adjustments.create(:source_type => "StoreCredit",  :label => I18n.t(:store_credit) , :amount => -5)

      order.store_credit_amount.should == 15
    end
  end

  context "consume_users_credit" do
    let(:store_credit_1) { mock_model(StoreCredit, :amount => 100, :remaining_amount => 100) }
    let(:store_credit_2) { mock_model(StoreCredit, :amount => 10, :remaining_amount => 5) }
    let(:store_credit_3) { mock_model(StoreCredit, :amount => 60, :remaining_amount => 50 ) }
    before { order.stub(:completed? => true, :store_credit_amount => 35) }

    it "should reduce remaining amount on a single credit when that credit satisfies the entire amount" do
      user.stub(:store_credits => [store_credit_1])
      store_credit_1.should_receive(:remaining_amount=).with(65)
      store_credit_1.should_receive(:save)
      order.send(:consume_users_credit)
    end

    it "should reduce remaining amount on a mutliple creidts when a single credit does not satify the entire amount" do
      order.stub(:store_credit_amount => 55)
      user.stub(:store_credits => [store_credit_2, store_credit_3])
      store_credit_2.should_receive(:update_attribute).with(:remaining_amount, 0)
      store_credit_3.should_receive(:update_attribute).with(:remaining_amount, 0)
      order.send(:consume_users_credit)
    end

    it "should call consume_users_credit after transition to complete" do
      order = Order.new()
      order.state = "confirm"
      order.should_receive(:consume_users_credit).at_least(1).times
      order.next!
    end

  end


  context "ensure_sufficient_credit" do
    before do
      order.adjustments.create(:source_type => "StoreCredit",  :label => I18n.t(:store_credit) , :amount => -10)
      order.stub(:completed? => true, :store_credit_amount => 35, :payment => mock_model(Payment))
    end

    it "should do nothing when user has credits" do
      order.store_credits.should_not_receive(:destroy_all)
      order.payment.should_not_receive(:amount=).with(50)
      order.send(:ensure_sufficient_credit)
    end

    context "when user no longer has sufficient credit to cover entire credit amount" do
      before { user.stub(:store_credits_total => 0.0) }

      it "should destory all store credit adjustments" do
        order.payment.stub(:amount= => true, :save => true)
        order.store_credits.should_receive(:destroy_all)
        order.send(:ensure_sufficient_credit)
      end

      it "should update payment" do
        order.payment.should_receive(:amount=).with(50)
        order.payment.should_receive(:save)
        order.send(:ensure_sufficient_credit)
      end
    end

  end

  context "process_payments!" do
    it "should return false when total is greater than zero and payment is nil" do
      order.process_payments!.should be_false
    end

    it "should return true when total is zero and payment is nil" do
      order.stub(:total => 0.0)
      order.process_payments!.should be_true
    end

    it "should return true when total is zero and payment is not nil" do
      order.stub(:payment => mock_model(Payment, :process! => true))
      order.process_payments!.should be_true
    end

    it "should process payment when total is zero and payment is not nil" do
      order.stub(:payments => [mock_model(Payment)])
      order.payment.should_receive(:process!)
      order.process_payments!
    end

  end
end
