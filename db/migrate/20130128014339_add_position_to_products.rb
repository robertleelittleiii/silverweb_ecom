# frozen_string_literal: true

class AddPositionToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :position, :integer
  end

  def self.down
    remove_column :products, :position
  end
end
