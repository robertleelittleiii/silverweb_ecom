class CreateProductRelatedProducts < ActiveRecord::Migration
  def change
    create_table :product_related_products do |t|
      t.integer :product_id
      t.integer :related_product_id

      t.timestamps null: false
    end
  end
end
