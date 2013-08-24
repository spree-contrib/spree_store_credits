module Spree
  class Promotion::Actions::GiveStoreCredit < PromotionAction
    preference :amount, :decimal, :default => 0.0

    def perform(options = {})
      user = lookup_user(options)
      give_store_credit(user) if user.present?
    end

    def lookup_user(options)
      options[:user]
    end

    def give_store_credit(user)
      user.store_credits.create(:amount => preferred_amount, :remaining_amount => preferred_amount,  
                                :reason => credit_reason)
    end

    def credit_reason
      "#{Spree.t(:promotion)} #{promotion.name}"
    end
  end
end
