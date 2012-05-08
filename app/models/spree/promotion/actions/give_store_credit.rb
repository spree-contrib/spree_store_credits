class Spree::Promotion::Actions::GiveStoreCredit < Spree::PromotionAction
  preference :amount, :decimal, :default => 0.0
  attr_accessible :preferred_amount

  def perform(options = {})
    if _user = options[:user]
      _user.store_credits.create(:amount => preferred_amount, :remaining_amount => preferred_amount,  :reason => "Promotion: #{promotion.name}")
    end
  end

end
