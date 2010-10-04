CheckoutController.class_eval do
  before_filter :remove_payments_attributes_if_total_is_zero
  
  private
  def remove_payments_attributes_if_total_is_zero
    return unless params[:order] && params[:order][:store_credit_amount]
    store_credit_amount = [BigDecimal.new(params[:order][:store_credit_amount]), current_user.store_credits_total].min
    if store_credit_amount >= current_order.total
      params[:order].delete(:source_attributes)
      params.delete(:payment_source)
      params[:order].delete(:payments_attributes)
    end
  end
end
