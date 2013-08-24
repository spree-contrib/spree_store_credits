class StoreCreditMinimumValidator < ActiveModel::Validator
  include ActionView::Helpers::NumberHelper

  def validate(record)
    return unless Spree::Config[:use_store_credit_minimum]
    return if record.item_total >= Spree::Config[:use_store_credit_minimum]
    return unless record.errors.empty?

    store_credit_amount = record.instance_variable_get(:@store_credit_amount).to_f
    if store_credit_amount > 0
      record.errors.add :base, 
                        Spree.t("errors.messages.store_credit_minimum_order_not_reach", 
                                amount: number_to_currency(Spree::Config[:use_store_credit_minimum].to_f))
    end
  end
end
