Order.class_eval do
  attr_accessible :store_credit_amount
  attr_accessor :store_credit_amount
  before_save :process_store_credit, :if => "@store_credit_amount"
  has_many :store_credits, :conditions => "source_type='StoreCredit'"
  
  private
  def process_store_credit
    @store_credit_amount = BigDecimal.new(@store_credit_amount.to_s).round(2)
    if @store_credit_amount > 0 && user && user.store_credits_total > 0
      transaction do
        if user.reload.store_credits_total >= @store_credit_amount
          StoreCreditAdjustment.create(
            :order => self,
            :label => I18n.t(:store_credit),
            :amount => -@store_credit_amount.abs
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
end
