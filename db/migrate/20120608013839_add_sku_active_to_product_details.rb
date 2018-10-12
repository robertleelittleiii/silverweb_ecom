# frozen_string_literal: true

class AddSkuActiveToProductDetails < ActiveRecord::Migration[5.0]
  def self.up
    add_column :product_details, :sku_active, :boolean
  end

  def self.down
    remove_column :product_details, :sku_active
  end
end
