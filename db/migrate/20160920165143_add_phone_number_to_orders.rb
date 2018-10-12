# frozen_string_literal: true

class AddPhoneNumberToOrders < ActiveRecord::Migration[5.0]
  def change
    add_column :orders, :bill_phone, :string
    add_column :orders, :ship_phone, :string
  end
end
