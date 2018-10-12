# frozen_string_literal: true

class CreatePremissionsForRetailers < ActiveRecord::Migration[5.0]
  def self.up
    # assign them to Admin role.
    role_admin = Role.find_by_name('Admin')
    role_cust = Role.find_by_name('Customer')
    role_siteowner = Role.find_by_name('Site Owner')

    right = Right.create name: '*Access to all Retailers actions', controller: 'retailers', action: '*'
    role_admin.rights << right
    role_siteowner.rights << right

    role_siteowner.save
    role_cust.save
    role_admin.save
  end

  def self.down
    # Destroy all rights
    right = Right.find_by_name('*Access to all Retailers actions')
    begin
      right.destroy
    rescue StandardError
      puts('Retailers permissions not found.')
    end
  end
end
