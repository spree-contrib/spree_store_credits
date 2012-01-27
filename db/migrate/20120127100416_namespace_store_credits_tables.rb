class NamespaceStoreCreditsTables < ActiveRecord::Migration
  def change
    rename_table :store_credits, :spree_store_credits
  end
end
