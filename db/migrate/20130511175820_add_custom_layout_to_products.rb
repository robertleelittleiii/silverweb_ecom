# frozen_string_literal: true

class AddCustomLayoutToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :custom_layout, :string
  end

  def self.down
    remove_column :products, :custom_layout
  end
end
