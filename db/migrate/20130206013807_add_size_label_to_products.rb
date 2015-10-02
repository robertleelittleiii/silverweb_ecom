class AddSizeLabelToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :size_label, :string
  end

  def self.down
    remove_column :products, :size_label
  end
end
