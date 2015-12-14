class UpdateOrderTransactions < ActiveRecord::Migration
  def up
    change_column :order_transactions, :message, :text
  end
  def down
    change_column :order_transactions, :message, :string
  end
end
