# frozen_string_literal: true

class CreateCouponOrders < ActiveRecord::Migration[5.0]
  def self.up
    create_table :coupon_orders do |t|
      t.integer :order_id
      t.integer :coupon_id

      t.timestamps
    end
  end

  def self.down
    drop_table :coupon_orders
  end
end
