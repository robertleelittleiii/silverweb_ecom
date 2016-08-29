class AddNoCouponToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :no_coupon, :boolean
  end

  def self.down
    remove_column :products, :no_coupon
  end
end
