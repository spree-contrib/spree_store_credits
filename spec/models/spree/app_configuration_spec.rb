require 'spec_helper'

describe Spree::AppConfiguration do
  subject { Spree::AppConfiguration.new }

  it 'should have the use_store_credit_minimum preference' do
    subject.should respond_to(:preferred_use_store_credit_minimum)
    subject.should respond_to(:preferred_use_store_credit_minimum=)
  end
end