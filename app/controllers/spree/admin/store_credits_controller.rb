module Spree
  class Admin::StoreCreditsController < Admin::ResourceController
    before_filter :check_amounts, :only => [:edit, :update]
    prepend_before_filter :set_remaining_amount, :only => [:create, :update]

    protected
      def permitted_resource_params
        params.require(:store_credit).permit(permitted_store_credit_attributes)
      end

    private
    def check_amounts
      if (@store_credit.remaining_amount < @store_credit.amount)
        flash[:error] = Spree.t(:cannot_edit_used)
        redirect_to spree.admin_store_credits_path
      end
    end

    def set_remaining_amount
      params[:store_credit][:remaining_amount] = params[:store_credit][:amount] if params[:store_credit]
    end

    def collection
      # TODO: PMG - Figure out how we can integrate with accessible_by
      Spree::StoreCredit.all.page(params[:page] || 1)
    end

    def permitted_store_credit_attributes
      [:user_id, :amount, :reason, :remaining_amount]
    end

  end
end
