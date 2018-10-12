# frozen_string_literal: true

class CouponOrder < ActiveRecord::Base
  belongs_to :coupon, optional: true
  belongs_to :order, optional: true
end
