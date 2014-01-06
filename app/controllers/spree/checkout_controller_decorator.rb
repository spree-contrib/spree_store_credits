module Spree
  CheckoutController.class_eval do
    before_filter :remove_payments_attributes_if_total_is_zero

    private
    def remove_payments_attributes_if_total_is_zero
      load_order

      return unless params[:order] && params[:order][:store_credit_amount]
      parsed_credit = Spree::Price.new
      parsed_credit.price = params[:order][:store_credit_amount]
      store_credit_amount = [parsed_credit.price, spree_current_user.store_credits_total].min
      if store_credit_amount >= (current_order.total + @order.store_credit_amount)
        params[:order].delete(:source_attributes)
        params.delete(:payment_source)
        params[:order].delete(:payments_attributes)
      end
    end
  end
end
