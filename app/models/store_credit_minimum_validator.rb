class StoreCreditMinimumValidator < ActiveModel::Validator
  def validate(record)
    if Spree::Config[:use_store_credit_minimum] and record.item_total < Spree::Config[:use_store_credit_minimum].to_f and record.store_credit_amount > 0
      record.errors[:base] <<  "Order's item total is less than the minimum allowed (#{Spree::Config[:use_store_credit_minimum].to_f}) to use store credit."
    end
  end
end
