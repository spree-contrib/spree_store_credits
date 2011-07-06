UsersController.class_eval do
  before_filter :find_orders_with_store_credit, :only => :show
  
  private
  
  def find_orders_with_store_credit
    @orders_with_store_credit = @user.orders.joins(:adjustments).where(:adjustments => {:source_type => 'StoreCredit'})
  end
end
