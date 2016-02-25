class AddSearchTermsToProducts < ActiveRecord::Migration
  def change
    add_column :products, :search_terms, :string
    add_index :products, :search_terms
  end
end
