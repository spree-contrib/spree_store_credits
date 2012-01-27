module Spree
  User.class_eval do
    has_many :store_credits

    def has_store_credit?
      store_credits.present?
    end

    def store_credits_total
      store_credits.sum(:remaining_amount)
    end
  end
end
