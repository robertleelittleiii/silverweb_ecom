# frozen_string_literal: true

class CreateCoupons < ActiveRecord::Migration[5.0]
  def self.up
    create_table :coupons do |t|
      t.text :description
      t.date :start_date
      t.date :end_date
      t.text :coupon_code
      t.float :value
      t.float :min_amount
      t.integer :coupon_type

      t.timestamps
    end
  end

  def self.down
    drop_table :coupons
  end
end
