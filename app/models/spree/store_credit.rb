class Spree::StoreCredit < ActiveRecord::Base
  validates :amount, :presence => true, :numericality => true
  validates :reason, :presence => true
  validates :user, :presence => true

  belongs_to :user, :class_name => Spree.user_class.to_s
  belongs_to :creator, :foreign_key => :admin_id, :class_name => Spree.user_class.to_s
end