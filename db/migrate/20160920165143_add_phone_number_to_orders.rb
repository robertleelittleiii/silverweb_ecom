class AddPhoneNumberToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :bill_phone, :string
    add_column :orders, :ship_phone, :string
  end
end
