Order.class_eval do
  attr_accessible :store_credit_amount, :remove_store_credits
  attr_accessor :store_credit_amount, :remove_store_credits
  before_save :process_store_credit, :if => "@store_credit_amount"
  before_save :remove_store_credits
  has_many :store_credits, :class_name => 'StoreCreditAdjustment', :conditions => "source_type='StoreCredit'"
  
  private
  def process_store_credit
    @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)
    if @store_credit_amount > 0 && user && user.store_credits_total > 0
      transaction do
        if user.reload.store_credits_total >= @store_credit_amount
          StoreCreditAdjustment.create(
            :order => self,
            :label => I18n.t(:store_credit),
            :amount => -@store_credit_amount.abs,
            :source_type => "StoreCredit"
          )

          user.store_credits.each do |store_credit|
            break if @store_credit_amount <= 0.005
            if store_credit.remaining_amount > 0
              if store_credit.remaining_amount > @store_credit_amount
                store_credit.remaining_amount -= @store_credit_amount
                store_credit.save
                @store_credit_amount = 0
              else
                @store_credit_amount -= store_credit.remaining_amount
                store_credit.update_attribute(:remaining_amount, 0)
              end
            end
          end
        end
      end
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
