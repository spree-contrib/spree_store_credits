# this :promotion factory is defined in spree_promo, but I can't reuse it (i believe) b/c it is in spec/factories vs. lib/....
Factory.define :promotion, :class => Spree::Promotion, :parent => :activator do |f|
  f.name 'Promo'
end

Factory.define :give_store_credit_action, :class => Spree::Promotion::Actions::GiveStoreCredit do |f|
  f.association :promotion

  f.after_create do |action|
    action.set_preference(:amount, 1234.56)
    action.save!
  end
end

Factory.define :promotion_for_store_credits, :parent => :promotion do |f|
  f.event_name "spree.user.signup"
  f.after_create do |p|
    p.promotion_actions [FactoryGirl.create(:give_store_credit_action, :promotion => p)]
  end
end
