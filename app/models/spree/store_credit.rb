class Spree::StoreCredit < ActiveRecord::Base
  attr_accessible :user_id, :amount, :reason, :remaining_amount

  validates :amount, :presence => true, :numericality => true
  validates :reason, :presence => true
  validates :user, :presence => true
  if Spree.user_class
    belongs_to :user, :class_name => Spree.user_class.to_s
  else
    belongs_to :user
    attr_accessible :amount, :remaining_amount, :reason, :user_id
  end
end
