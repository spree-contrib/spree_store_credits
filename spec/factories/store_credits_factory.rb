require 'bigdecimal'
FactoryGirl.define do
  factory :store_credit, class: Spree::StoreCredit do
    amount { BigDecimal.new(rand()*100, 2) }
    reason { SecureRandom.hex(5) }
    user
  end

  factory :give_store_credit_action, :class => Spree::Promotion::Actions::GiveStoreCredit do |f|
    association :promotion

    after(:create) do |action|
      action.set_preference(:amount, 1234.56)
      action.save!
    end
  end

  factory :promotion_for_store_credits, :parent => :promotion do
    event_name "spree.user.signup"
    after(:create) do |p|
      p.promotion_actions [create(:give_store_credit_action, :promotion => p)]
    end
  end
end

