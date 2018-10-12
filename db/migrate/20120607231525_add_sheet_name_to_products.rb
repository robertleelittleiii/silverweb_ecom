# frozen_string_literal: true

class AddSheetNameToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :sheet_name, :string
  end

  def self.down
    remove_column :products, :sheet_name
  end
end
