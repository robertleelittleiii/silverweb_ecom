# frozen_string_literal: true

class AddCatetoryToCoupons < ActiveRecord::Migration[5.0]
  def self.up
    add_column :coupons, :category_id, :string
  end

  def self.down
    remove_column :coupons, :category_id
  end
end
