Spree::AppConfiguration.class_eval do
  preference :use_store_credit_minimum, :decimal, :default => 0.0
end
