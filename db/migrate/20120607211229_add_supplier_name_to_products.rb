# frozen_string_literal: true

class AddSupplierNameToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :supplier_name, :string
  end

  def self.down
    remove_column :products, :supplier_name
  end
end
