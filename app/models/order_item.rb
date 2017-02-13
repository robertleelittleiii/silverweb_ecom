class OrderItem < ActiveRecord::Base
  
  belongs_to :order
  belongs_to :product
  belongs_to :product_detail
  
  
  def self.from_cart_item(cart_item)
    if cart_item.quantity == 0 then
      nil
    else
    oi = self.new
    oi.product_id     = cart_item.product.id
    oi.product_detail_id = cart_item.product_detail.id
    oi.quantity    = cart_item.quantity
    oi.price = cart_item.price
    oi.color = cart_item.color
    oi.size = cart_item.size
    oi.title = cart_item.title
    oi.description = ActionView::Base.full_sanitizer.sanitize(cart_item.description).truncate(250)

    oi
  end
end
end
