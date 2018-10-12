# frozen_string_literal: true

class AddPositionToProductRelatedProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :product_related_products, :position, :integer
  rescue StandardError
    ''
  end
end
