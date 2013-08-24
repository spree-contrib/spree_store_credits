require 'spec_helper'

require 'active_model'
require 'rspec/rails/extensions'

class StoreCreditMinimumValidatable
  include ActiveModel::Validations
  attr_accessor :store_credit_amount
  attr_accessor :item_total
  attr_accessor :other_validated_attr
  validates :other_validated_attr, presence: true
  validates_with StoreCreditMinimumValidator
end

describe StoreCreditMinimumValidator do
  subject { StoreCreditMinimumValidatable.new }

  before do
    subject.other_validated_attr = 'valid'
  end

  context 'when the use_store_credit_minimum configuration value is not set' do
    before do
      Spree::Config[:use_store_credit_minimum] = nil
      subject.item_total = 200.00
    end

    it 'should not validate if there is no store credit' do
      expect(subject).to be_valid
    end

    it 'should not validate if there is a store credit' do
      subject.store_credit_amount = 100.00
      expect(subject).to be_valid
    end
  end

  context 'when the use_store_credit_minimum configuration value is set' do
    before do
      Spree::Config[:use_store_credit_minimum] = 20.00
      subject.item_total = 10.00
    end

    it 'should not validate if there is no store credit' do
      expect(subject).to be_valid
    end

    it 'should not validate if there is a store credit and the total is below the minimum' do
      subject.store_credit_amount = 10.00
      expect(subject).not_to be_valid
      expect(subject.errors[:base]).not_to be_empty
      expect(subject.errors[:base]).to eq(["Order's item total is less than the minimum allowed ($20.00) to use store credit."])
    end

    it 'should not add a validation error if an error already exists' do
      subject.other_validated_attr = nil
      expect(subject).not_to be_valid

      subject.store_credit_amount = 10.00
      expect(subject).not_to be_valid
      expect(subject.errors[:base]).to be_empty
    end

    it 'should validate if there is a store credit and the total is below the minimum' do
      subject.item_total = 20.00
      subject.store_credit_amount = 10.00
      expect(subject).to be_valid
    end
  end
end
