class AddUseSizeAsPriceToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :use_size_as_price, :boolean
  end
end
