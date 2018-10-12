# frozen_string_literal: true

class UpdateOrderTransactions < ActiveRecord::Migration[5.0]
  def up
    change_column :order_transactions, :message, :text
  end

  def down
    change_column :order_transactions, :message, :string
  end
end
