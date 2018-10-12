# frozen_string_literal: true

class AddSearchTermsToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :search_terms, :string
    add_index :products, :search_terms
  end
end
