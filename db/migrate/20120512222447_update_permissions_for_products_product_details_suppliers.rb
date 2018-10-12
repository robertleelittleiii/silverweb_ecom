# frozen_string_literal: true

class UpdatePermissionsForProductsProductDetailsSuppliers < ActiveRecord::Migration[5.0]
  def self.up
    # assign them to Admin role.
    role_admin = Role.find_by_name('Admin')
    role_cust = Role.find_by_name('Customer')
    role_siteowner = Role.find_by_name('Site Owner')

    right = Right.create name: '*Access to all products actions', controller: 'products', action: '*'
    role_admin.rights << right
    role_siteowner.rights << right

    right = Right.create name: '*Access to all supplier actions', controller: 'suppliers', action: '*'
    role_admin.rights << right
    role_siteowner.rights << right

    right = Right.create name: '*Access to all product_detail actions', controller: 'product_details', action: '*'
    role_admin.rights << right
    role_siteowner.rights << right

    right = Right.create name: '*Access to all slider actions', controller: 'sliders', action: '*'
    role_admin.rights << right
    role_siteowner.rights << right

    role_siteowner.save
    role_cust.save
    role_admin.save
  end

  def self.down
    # Destroy all rights
    right = Right.find_by_name('*Access to all products actions')
    begin
      right.destroy
    rescue StandardError
      puts('products right not found.')
    end

    right = Right.find_by_name('*Access to all supplier actions')
    begin
      right.destroy
    rescue StandardError
      puts('supplier right not found.')
    end

    right = Right.find_by_name('*Access to all product_detail actions')
    begin
      right.destroy
    rescue StandardError
      puts('product_detail right not found.')
    end

    right = Right.find_by_name('*Access to all slider actions')
    begin
      right.destroy
    rescue StandardError
      puts('slider right not found.')
    end
  end
end
