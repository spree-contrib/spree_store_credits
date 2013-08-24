require 'spec_helper'

describe Spree::StoreCredit do
  it { should respond_to(:amount) }
  it { should respond_to(:reason) }
  it { should respond_to(:user) }

  context '#validations' do
    it 'should ensure the presence of an amount' do
      sc = build(:store_credit)
      sc.should be_valid
      sc.amount = nil
      sc.should_not be_valid
    end

    it 'should ensure the numericality of an amount' do
      sc = build(:store_credit)
      sc.should be_valid
      sc.amount = 'not_a_number'
      sc.should_not be_valid
    end

    it 'should ensure the presence of a reason' do
      sc = build(:store_credit)
      sc.should be_valid
      sc.reason = nil
      sc.should_not be_valid
    end

    it 'should ensure the presence of a user' do
      sc = build(:store_credit)
      sc.should be_valid
      sc.user = nil
      sc.should_not be_valid
    end
  end
end