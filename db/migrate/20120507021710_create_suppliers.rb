# frozen_string_literal: true

class CreateSuppliers < ActiveRecord::Migration[5.0]
  def self.up
    create_table :suppliers do |t|
      t.string :supplier_name
      t.string :contact_name
      t.string :address_1
      t.string :address_2
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :country
      t.string :phone_number
      t.string :fax_number
      t.string :email_address
      t.string :web_site

      t.timestamps
    end
  end

  def self.down
    drop_table :suppliers
  end
end
