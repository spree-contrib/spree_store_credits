class CreateStoreCredits < ActiveRecord::Migration
  def self.up
    create_table :store_credits do |t|
      t.references :user
      t.decimal :amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.decimal :remaining_amount, :precision => 8, :scale => 2, :default => 0.0, :null => false
      t.string :reason
      t.timestamps
    end
  end

  def self.down
    drop_table :store_credits
  end
end
