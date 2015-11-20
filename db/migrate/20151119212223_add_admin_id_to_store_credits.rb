class AddAdminIdToStoreCredits < ActiveRecord::Migration
  def self.up
    change_table :spree_store_credits do |t|
      t.integer :admin_id
    end
  end

  def self.down
    change_table :spree_store_credits do |t|
      t.remove :admin_id
    end
  end
end