class StoreCredit < ActiveRecord::Base
  validates :amount, :presence => true, :numericality => true
  validates :reason, :presence => true
  validates :user, :presence => true
  
  belongs_to :user
  before_create :set_remaining_amount
  
  private
  
  def set_remaining_amount
    self.remaining_amount = self.amount
  end
end
