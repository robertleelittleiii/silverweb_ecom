class Coupon < ActiveRecord::Base
    has_many :order_associations, class_name: "CouponOrders"
    
    has_many :coupon_usages
  
  
   COUPON_TYPES =  [
    ["Dollar amount off of price.", 1],
    ["Percent off of price.", 2],
    ["Free shipping credit", 3],
    ["Free shipping full", 4],
    ["Special: Sale by collection",5]
  ].freeze

  
  def self.find_coupon(code)
    return Coupon.where(coupon_code: code).where("? BETWEEN `start_date` AND `end_date`",Date.today).first
    
  end
  
  def self.active
    not Right.where(controller: "coupons").first.blank?
  end
end
  
