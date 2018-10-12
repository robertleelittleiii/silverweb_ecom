# frozen_string_literal: true

class AddSizeLabelToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :size_label, :string
  end

  def self.down
    remove_column :products, :size_label
  end
end
