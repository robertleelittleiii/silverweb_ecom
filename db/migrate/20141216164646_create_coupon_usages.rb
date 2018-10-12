# frozen_string_literal: true

class CreateCouponUsages < ActiveRecord::Migration[5.0]
  def self.up
    unless ActiveRecord::Base.connection.table_exists? 'coupon_usages'

      create_table :coupon_usages do |t|
        t.integer :coupon_id
        t.integer :user_id
        t.integer :usage_count

        t.timestamps
      end
    end
  end

  def self.down
    if ActiveRecord::Base.connection.table_exists? 'coupon_usages'
      drop_table :coupon_usages
    end
  end
end
