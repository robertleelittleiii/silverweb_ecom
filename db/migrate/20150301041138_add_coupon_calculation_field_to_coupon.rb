class AddCouponCalculationFieldToCoupon < ActiveRecord::Migration
  def self.up
    add_column :coupons, :coupon_calc, :string
  end

  def self.down
    remove_column :coupons, :coupon_calc
  end
end
