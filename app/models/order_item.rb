# frozen_string_literal: true

class OrderItem < ActiveRecord::Base
  belongs_to :order, optional: true
  belongs_to :product, optional: true
  belongs_to :product_detail, optional: true

  def self.from_cart_item(cart_item)
    if cart_item.quantity == 0
      nil
    else
      oi = new
      oi.product_id = cart_item.product.id
      oi.product_detail_id = cart_item.product_detail.id
      oi.quantity = cart_item.quantity
      oi.price = cart_item.price
      oi.color = cart_item.color
      oi.size = cart_item.size
      oi.title = cart_item.title
      oi.description = ActionView::Base.full_sanitizer.sanitize(cart_item.description).truncate(250)

      oi
  end
end
end
