# frozen_string_literal: true

class CouponUsage < ActiveRecord::Base
  belongs_to :user, optional: true
  belongs_to :coupon, optional: true
end
