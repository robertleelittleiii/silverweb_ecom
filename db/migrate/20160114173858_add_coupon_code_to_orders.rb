class AddCouponCodeToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :coupon_code, :string
  end

  def self.down
    remove_column :orders, :coupon_code
  end
end
