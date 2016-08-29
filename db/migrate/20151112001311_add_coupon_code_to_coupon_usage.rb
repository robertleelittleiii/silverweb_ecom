class AddCouponCodeToCouponUsage < ActiveRecord::Migration
  def self.up
    add_column :coupon_usages, :coupon_code, :string
  end

  def self.down
    remove_column :coupon_usages, :coupon_code
  end
end
