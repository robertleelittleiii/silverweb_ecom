class AddPositionToProductRelatedProducts < ActiveRecord::Migration
  def change
    add_column :product_related_products, :position, :integer
  end
end
