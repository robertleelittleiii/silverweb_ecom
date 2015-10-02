class CreateCouponUsages < ActiveRecord::Migration
  def self.up
    create_table :coupon_usages do |t|
      t.integer :coupon_id
      t.integer :user_id
      t.integer :usage_count

      t.timestamps
    end
  end

  def self.down
    drop_table :coupon_usages
  end
end
