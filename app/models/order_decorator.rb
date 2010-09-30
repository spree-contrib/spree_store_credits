Order.class_eval do
  attr_accessible :store_credit_amount, :remove_store_credits
  attr_accessor :store_credit_amount, :remove_store_credits
  before_save :process_store_credit, :if => "@store_credit_amount"
  before_save :remove_store_credits
  has_many :store_credits, :class_name => 'StoreCreditAdjustment', :conditions => "source_type='StoreCredit'"
  
  def store_credit_amount
    store_credits.sum(:amount).abs
  end
  
  
  private
  def process_store_credit
    return if self.total == 0
    @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)
    delta_amount = store_credits.present? ? 
                    @store_credit_amount - store_credit_amount :
                    @store_credit_amount
    # store credit can't be greater than order total
    delta_amount = [delta_amount, self.total].min

    if @store_credit_amount > 0 && user && user.store_credits_total > 0
      transaction do
        if user.reload.store_credits_total >= delta_amount
          sca = StoreCreditAdjustment.find_or_create_by_order_id_and_source_type(self.id, "StoreCredit")
          sca.update_attributes({:amount => -(delta_amount + store_credit_amount), :label => I18n.t(:store_credit)})

          user.store_credits.each do |store_credit|
            break if delta_amount == 0
            if store_credit.remaining_amount > 0
              if store_credit.remaining_amount > delta_amount
                store_credit.remaining_amount -= delta_amount
                store_credit.save
                delta_amount = 0
              else
                delta_amount -= store_credit.remaining_amount
                store_credit.update_attribute(:remaining_amount, 0)
              end
            end
          end
          
          self.update_totals
        end
      end
      @store_credit_amount = 0
    end
  end
  
  def remove_store_credits
    if @remove_store_credits == '1'
      amount_return = store_credits.sum(:amount).abs
      if amount_return > 0
        transaction do
          StoreCredit.create(:user => user, :amount => amount_return, :reason => "Return")
          store_credits.clear
        end
      end
    end
  end
end
