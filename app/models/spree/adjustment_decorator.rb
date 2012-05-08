Spree::Adjustment.class_eval do
  scope :store_credits, lambda { where(:source_type => 'Spree::StoreCredit') }
end