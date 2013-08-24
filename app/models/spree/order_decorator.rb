Spree::Order.class_eval do
  attr_accessor :store_credit_amount, :remove_store_credits

  # the check for user? below is to ensure we don't break the
  # admin app when creating a new order from the admin console
  # In that case, we create an order before assigning a user
  before_save :process_store_credit, :if => "self.user.present? && @store_credit_amount"
  after_save :ensure_sufficient_credit, :if => "self.user.present? && !self.completed?"

  validates_with StoreCreditMinimumValidator

  def process_payments_with_credits!
    if total > 0 && pending_payments.empty?
      false
    else
      process_payments_without_credits!
    end
  end
  alias_method_chain :process_payments!, :credits

  def store_credit_amount
    adjustments.store_credits.sum(:amount).abs.to_f
  end

  # in case of paypal payment, item_total cannot be 0
  def store_credit_maximum_amount
    item_total - 0.01
  end

  # returns the maximum usable amount of store credits
  def store_credit_maximum_usable_amount
    if user.store_credits_total > 0
      user.store_credits_total > store_credit_maximum_amount ? store_credit_maximum_amount : user.store_credits_total
    else
      0
    end
  end

  private

  # credit or update store credit adjustment to correct value if amount specified
  #
  def process_store_credit
    @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)

    # store credit can't be greater than order total (not including existing credit), or the user's available credit
    @store_credit_amount = [@store_credit_amount, user.store_credits_total, (total + store_credit_amount.abs)].min

    if @store_credit_amount <= 0
      adjustments.store_credits.destroy_all
    else
      if sca = adjustments.store_credits.first
        sca.update_attributes({:amount => -(@store_credit_amount)})
      else
        # create adjustment off association to prevent reload
        sca = adjustments.store_credits.create(:label => Spree.t(:store_credit) , :amount => -(@store_credit_amount))
      end
    end

    # recalc totals and ensure payment is set to new amount
    update_totals
    pending_payments.first.amount = total if pending_payments.first
  end

  def consume_users_credit
    return unless completed? and user.present?
    credit_used = self.store_credit_amount

    user.store_credits.each do |store_credit|
      break if credit_used == 0
      if store_credit.remaining_amount > 0
        if store_credit.remaining_amount > credit_used
          store_credit.remaining_amount -= credit_used
          store_credit.save
          credit_used = 0
        else
          credit_used -= store_credit.remaining_amount
          store_credit.update_attribute(:remaining_amount, 0)
        end
      end
    end
  end
  # consume users store credit once the order has completed.
  state_machine.after_transition :to => :complete,  :do => :consume_users_credit

  # ensure that user has sufficient credits to cover adjustments
  #
  def ensure_sufficient_credit
    if user.store_credits_total < store_credit_amount
      # user's credit does not cover all adjustments.
      adjustments.store_credits.destroy_all

      update!
    end
  end

end
