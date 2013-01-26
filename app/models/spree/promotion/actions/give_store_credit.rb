module Spree
  class Promotion::Actions::GiveStoreCredit < PromotionAction
    preference :amount, :decimal, :default => 0.0
    attr_accessible :preferred_amount

    def perform(options = {})
      if user = options[:user]
        user.store_credits.create(:amount => preferred_amount, :remaining_amount => preferred_amount,  :reason => "Promotion: #{promotion.name}")
      else
      end
    end
  end
end
