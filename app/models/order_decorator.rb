Order.class_eval do
  attr_accessible :store_credit_amount, :remove_store_credits
  attr_accessor :store_credit_amount, :remove_store_credits
  before_save :process_store_credit, :if => "@store_credit_amount"
  before_save :remove_store_credits
  after_save :ensure_sufficient_credit

  has_many :store_credits, :class_name => 'StoreCreditAdjustment', :conditions => "source_type='StoreCredit'"

  def store_credit_amount
    store_credits.sum(:amount).abs
  end


  # override core process payments to force payment present
  # in case store credits were destroyed by ensure_sufficient_credit
  def process_payments!
    if total > 0 && payment.nil?
      false
    else
      ret = payments.each(&:process!)
    end
  end


  private

  # credit or update store credit adjustment to correct value if amount specified
  #
  def process_store_credit
    @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)

    # store credit can't be greater than order total (not including existing credit), or the users available credit
    @store_credit_amount = [@store_credit_amount, user.store_credits_total, (total + store_credit_amount.abs)].min

    if @store_credit_amount <= 0
      if sca = adjustments.detect {|adjustment| adjustment.source_type == "StoreCredit" }
        sca.destroy
      end
    else
      if sca = adjustments.detect {|adjustment| adjustment.source_type == "StoreCredit" }
        sca.update_attributes({:amount => -(@store_credit_amount)})
      else
        #create adjustment off association to prevent reload
        sca = adjustments.create(:source_type => "StoreCredit",  :label => I18n.t(:store_credit) , :amount => -(@store_credit_amount))
      end

      #recalc totals and ensure payment is set to new amount
      update_totals
      payment.amount = total if payment
    end
  end

  # consume users store credit once the order has completed.
  fsm = self.state_machines[:state]
  fsm.after_transition :to => 'complete', :do => :consume_users_credit

  def consume_users_credit
    return unless completed?
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

  # ensure that user has sufficient credits to cover adjustments
  #
  def ensure_sufficient_credit
    if user.store_credits_total < store_credit_amount
      #user's credit does not cover all adjustments.
      store_credits.destroy_all

      update!
    end
  end

  def remove_store_credits
    store_credits.clear if @remove_store_credits == '1'
  end
end
