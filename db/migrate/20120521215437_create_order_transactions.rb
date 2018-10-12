# frozen_string_literal: true

class CreateOrderTransactions < ActiveRecord::Migration[5.0]
  def self.up
    create_table :order_transactions do |t|
      t.integer :order_id
      t.string :action
      t.integer :amount
      t.boolean :success
      t.string :authorization
      t.string :message
      t.text :params

      t.timestamps
    end
  end

  def self.down
    drop_table :order_transactions
  end
end
