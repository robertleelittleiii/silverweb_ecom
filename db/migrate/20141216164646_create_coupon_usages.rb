class CreateCouponUsages < ActiveRecord::Migration
  def self.up
    if not ActiveRecord::Base.connection.table_exists? 'coupon_usages' then

      create_table :coupon_usages do |t|
        t.integer :coupon_id
        t.integer :user_id
        t.integer :usage_count

        t.timestamps
      end
    end
        
  end

  def self.down
    if ActiveRecord::Base.connection.table_exists? 'coupon_usages' then
      drop_table :coupon_usages
    end
  end
end
