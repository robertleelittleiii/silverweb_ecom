class AddCustomLayoutToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :custom_layout, :string
  end

  def self.down
    remove_column :products, :custom_layout
  end
end
