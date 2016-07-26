class AddCatetoryToCoupons < ActiveRecord::Migration
  def self.up
    add_column :coupons, :category_id, :string
  end

  def self.down
    remove_column :coupons, :category_id
  end
end
