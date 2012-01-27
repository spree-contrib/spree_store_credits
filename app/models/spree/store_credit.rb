module Spree
  class StoreCredit < ActiveRecord::Base
    validates :amount, :presence => true, :numericality => true
    validates :reason, :presence => true
    validates :user, :presence => true

    belongs_to :user
  end
end
