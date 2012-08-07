module Spree
  class StoreCredit < ActiveRecord::Base
    attr_accessible :user_id, :amount, :reason, :remaining_amount

    validates :amount, :presence => true, :numericality => true
    validates :reason, :presence => true
    validates :user, :presence => true

    belongs_to :user
  end
end
