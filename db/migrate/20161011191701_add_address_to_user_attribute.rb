class AddAddressToUserAttribute < ActiveRecord::Migration
  def change
    add_column :user_attributes, :shipping_address, :string
    add_column :user_attributes, :shipping_city, :string
    add_column :user_attributes, :shipping_state, :string
    add_column :user_attributes, :shipping_zip_code, :string
    add_column :user_attributes, :billing_address, :string
    add_column :user_attributes, :billing_city, :string
    add_column :user_attributes, :billing_state, :string
    add_column :user_attributes, :billing_zip_code, :string
  end
end
