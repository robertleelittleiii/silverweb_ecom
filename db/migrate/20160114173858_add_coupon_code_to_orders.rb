# frozen_string_literal: true

class AddCouponCodeToOrders < ActiveRecord::Migration[5.0]
  def self.up
    add_column :orders, :coupon_code, :string
  end

  def self.down
    remove_column :orders, :coupon_code
  end
end
