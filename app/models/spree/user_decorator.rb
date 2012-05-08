if Spree.user_class
  Spree.user_class.class_eval do
    has_many :store_credits, :class_name => "Spree::StoreCredit"

    def has_store_credit?
      store_credits.present?
    end

    def store_credits_total
      store_credits.sum(:remaining_amount)
    end
  end
end
