# frozen_string_literal: true

class AddTaxableToProducts < ActiveRecord::Migration[5.0]
  def self.up
    add_column :products, :is_taxable, :boolean
  end

  def self.down
    remove_column :products, :is_taxable
  end
end
