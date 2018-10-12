# frozen_string_literal: true

class AddCouponCalculationFieldToCoupon < ActiveRecord::Migration[5.0]
  def self.up
    add_column :coupons, :coupon_calc, :string
  end

  def self.down
    remove_column :coupons, :coupon_calc
  end
end
