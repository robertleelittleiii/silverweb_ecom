# frozen_string_literal: true

class CartItem
  include ActiveModel::Conversion

  attr_reader :product, :product_detail, :quantity

  def initialize(product, product_detail, quantity)
    puts(product.inspect.to_s)
    puts(product_detail.inspect.to_s)
    @product = product
    @product_detail = product_detail
    @quantity = quantity.to_i
  end

  def persisted?
    true
  end

  def increment_quantity(quantity = 1)
    @quantity += quantity.to_i
    @quantity = product_detail.units_in_stock if @quantity > product_detail.units_in_stock
  end

  def decrement_quantity(quantity = 1)
    @quantity -= quantity.to_i
    @quantity = 0 if @quantity < 0
  end

  def quantity=(value = 0)
    @quantity = value
  end

  def title
    @product.product_name
  end

  def price
    if @product.use_size_as_price == true then
      @product_detail.price * @quantity.to_i
    else
      @product.price * @quantity.to_i
    end
  rescue StandardError
    0
  end

  def size
    @product_detail.size
  end

  def tax(tax_value)
    if @product.is_taxable == true
      @product.price * tax_value
    else
      0
    end
  end

  def color
    @product_detail.color
  end

  def picture
    @product.first_image.public_filename(:tiny)
    # "image_tag("+@product.images[0].public_filename(:tiny)+",:id=>"+product.id+",:border=>'0')"
  end

  def description
    @product.product_description
  end

  def [](key)
    send(key)
  end
end
