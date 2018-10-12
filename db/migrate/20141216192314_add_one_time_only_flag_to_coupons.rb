# frozen_string_literal: true

class AddOneTimeOnlyFlagToCoupons < ActiveRecord::Migration[5.0]
  def self.up
    add_column :coupons, :one_time_only, :boolean
    add_column :coupons, :only_most_expensive_item, :boolean
  end

  def self.down
    remove_column :coupons, :one_time_only
    remove_column :coupons, :only_most_expensive_item
  end
end
