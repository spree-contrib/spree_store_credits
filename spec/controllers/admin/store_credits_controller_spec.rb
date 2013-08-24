require 'spec_helper'

describe Spree::Admin::StoreCreditsController do
  stub_authorization!

  before do
    user = create(:admin_user)
    controller.stub(:spree_current_user => user)
  end

  context '#index' do
    context "with store credits" do
      let!(:store_credits) { 3.times.map{ create(:store_credit) } } 

      it "should display the index page" do
        spree_get :index
        response.status.should eq(200)
        response.should render_template(:index)
        assigned_credits = assigns(:collection)
        store_credits.each do |c|
          assigned_credits.should include(c)
        end
      end
    end

    context "without store credits" do
      it "should display an empty" do
        spree_get :index
        response.status.should eq(200)
        response.should render_template(:index)
        assigns(:collection).should be_empty
      end
    end
  end

  context '#new' do
    it 'should render the correct template' do
      spree_get :new
      response.status.should eq(200)
      response.should render_template(:new)
    end
  end

  context '#create' do
    let(:user) { create(:user) }
    let(:reason) { SecureRandom.hex(5) }
    let(:amount) { BigDecimal.new(rand()*100, 2).to_f }

    it 'should create a store credit for the user when arguments are provided' do
      lambda {
        spree_post :create, store_credit: { amount: amount, reason: reason, user_id: user.id }
        response.should redirect_to(spree.admin_store_credits_path)
      }.should change(Spree::StoreCredit, :count).by(1)
      user.reload
      store_credit = user.store_credits.first
      store_credit.should_not be_nil
      store_credit.user.should eq(user)
      store_credit.reason.should eq(reason)
      store_credit.amount.should eq(amount)
      store_credit.remaining_amount.should eq(amount)
    end
  end

  context '#edit' do
    let(:new_store_credit) { create(:store_credit, amount: 40.0, remaining_amount: 40.0) }
    let(:used_store_credit) { create(:store_credit, amount: 40.0, remaining_amount: 20.0) }

    it 'should render the correct template for a new store credit' do
      spree_get :edit, id: new_store_credit
      response.status.should eq(200)
      response.should render_template(:edit)
    end

    it 'should redirect to spree.admin_store_credits_path for a used store credit' do
      spree_get :edit, id: used_store_credit
      response.should redirect_to(spree.admin_store_credits_path)
      flash[:error].should eq("Cannot be edited because it has been used")
    end
  end

  context '#update' do
    let(:new_store_credit) { create(:store_credit, amount: 40.0, remaining_amount: 40.0) }
    let(:used_store_credit) { create(:store_credit, amount: 40.0, remaining_amount: 20.0) }

    it 'should update the value and redirect for a new store credit' do
      new_reason = SecureRandom.hex(5)
      spree_put :update, id: new_store_credit, store_credit: { amount: new_store_credit.amount,
                                                               remaining_amount: new_store_credit.remaining_amount,
                                                               user_id: new_store_credit.user,
                                                               reason: new_reason }
      new_store_credit.reload
      new_store_credit.reason.should eq(new_reason)
      flash[:error].should be_nil
      response.should redirect_to(spree.admin_store_credits_path)
    end

    it 'should redirect to spree.admin_store_credits_path for a used store credit' do
      old_reason = used_store_credit.reason
      new_reason = SecureRandom.hex(5)
      spree_put :update, id: used_store_credit, store_credit: { amount: used_store_credit.amount,
                                                                remaining_amount: used_store_credit.remaining_amount,
                                                                user_id: used_store_credit.user,
                                                                reason: new_reason }
      response.should redirect_to(spree.admin_store_credits_path)
      flash[:error].should eq("Cannot be edited because it has been used")
      used_store_credit.reload
      used_store_credit.reason.should eq(old_reason)
    end
  end

  context '#destroy' do
    let!(:store_credit) { create(:store_credit) }
    it 'should destroy the store credit' do
      lambda {
        spree_delete :destroy, id: store_credit.id
        response.should redirect_to(spree.admin_store_credits_path)
      }.should change(Spree::StoreCredit, :count).by(-1)
    end
  end
end