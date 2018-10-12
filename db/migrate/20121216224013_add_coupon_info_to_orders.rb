# frozen_string_literal: true

class AddCouponInfoToOrders < ActiveRecord::Migration[5.0]
  def self.up
    add_column :orders, :coupon_description, :string
    add_column :orders, :coupon_value, :float
  end

  def self.down
    remove_column :orders, :coupon_value
    remove_column :orders, :coupon_description
  end
end
