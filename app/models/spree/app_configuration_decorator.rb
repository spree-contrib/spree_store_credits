Spree::AppConfiguration.class_eval do
  preference :use_store_credit_minimum, :float, :default => 0.0
end
