module Spree
  CheckoutHelper.module_eval do

    def checkout_states
      if @order.payment.nil? || (@order.payment and @order.payment.payment_method.payment_profiles_supported?)
        %w(address delivery payment confirm complete)
      else
        %w(address delivery payment complete)
      end
    end

  end
end
