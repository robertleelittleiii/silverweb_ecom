class AddStoreWideSaleToOrders < ActiveRecord::Migration
  def self.up
    add_column :orders, :store_wide_sale, :float
  end

  def self.down
    remove_column :orders, :store_wide_sale
  end
end
