# frozen_string_literal: true

class AddNoCouponToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :no_coupon, :boolean
  end

  def self.down
    remove_column :products, :no_coupon
  end
end
