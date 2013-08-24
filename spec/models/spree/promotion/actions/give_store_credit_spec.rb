require 'spec_helper'

describe Spree::Promotion::Actions::GiveStoreCredit do
  let(:promotion) { create(:promotion) }
  subject { 
    a = Spree::Promotion::Actions::GiveStoreCredit.new
    a.promotion = promotion
    a.preferred_amount = 20.0
    a
  }

  context '#perform' do
    it 'passes the argument to lookup user, and passes a not nil return value to give_store_credit' do
      options_double = double
      user_double = double
      subject.should_receive(:lookup_user).with(options_double).and_return(user_double)
      subject.should_receive(:give_store_credit).with(user_double)
      subject.perform(options_double)
    end

    it 'passes the argument to lookup user, and does not give a store credit if no user is found' do
      options_double = double
      subject.should_receive(:lookup_user).with(options_double).and_return(nil)
      subject.should_not_receive(:give_store_credit)
      subject.perform(options_double)
    end
  end

  context '#lookup_user' do
    it 'pulls the user from the options hash' do
      user_double = double
      options = { user: user_double }
      subject.lookup_user(options).should eq(user_double)
    end
  end

  context '#give_store_credit' do
    let!(:user) { create(:user) }

    it 'adds a store credit with the specified amount and reason to the user' do
      lambda {
        subject.give_store_credit(user)
      }.should change(Spree::StoreCredit, :count).by(1)
      user.reload
      user.store_credits.size.should eq(1)
      last_credit = user.store_credits.first
      last_credit.should_not be_nil
      last_credit.amount.should eq(subject.preferred_amount)
      last_credit.reason.should eq(subject.credit_reason)
      last_credit.remaining_amount.should eq(last_credit.amount)
    end
  end

end