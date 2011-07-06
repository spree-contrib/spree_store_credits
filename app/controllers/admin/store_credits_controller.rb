class Admin::StoreCreditsController < Admin::ResourceController
  before_filter :check_amounts, :only => [:edit, :update]
  prepend_before_filter :set_remaining_amount, :only => [:create, :update]
  
  private
  def check_amounts
    if (@store_credit.remaining_amount < @store_credit.amount)
      flash[:error] = "Can't be edit, b/c already was used."
      redirect_to admin_store_credits_path
    end
  end
  
  def set_remaining_amount
    params[:store_credit][:remaining_amount] = params[:store_credit][:amount]
  end
end
