# frozen_string_literal: true

class AddStoreWideSaleToOrders < ActiveRecord::Migration[5.0]
  def self.up
    add_column :orders, :store_wide_sale, :float
  end

  def self.down
    remove_column :orders, :store_wide_sale
  end
end
