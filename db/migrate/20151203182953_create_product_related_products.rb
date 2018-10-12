# frozen_string_literal: true

class CreateProductRelatedProducts < ActiveRecord::Migration[5.0]
  def change
    unless ActiveRecord::Base.connection.table_exists? 'product_related_products'
      create_table :product_related_products do |t|
        t.integer :product_id
        t.integer :related_product_id

        t.timestamps null: false
      end
    end
  end
end
