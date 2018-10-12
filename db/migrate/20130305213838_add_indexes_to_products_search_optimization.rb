# frozen_string_literal: true

class AddIndexesToProductsSearchOptimization < ActiveRecord::Migration[5.0]
  def self.up
    add_index :products, :sheet_name
   end

  def self.down
    remove_index :products, :sheet_name
   end
end
