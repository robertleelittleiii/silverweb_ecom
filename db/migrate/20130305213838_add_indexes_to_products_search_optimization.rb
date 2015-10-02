class AddIndexesToProductsSearchOptimization < ActiveRecord::Migration
 def self.up
    add_index :products, :sheet_name
  end

  def self.down
    remove_index :products, :sheet_name
   end
end