class Cart 

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  
  attr_reader :items, :id, :coupon_code, :user_id, :shipping_type
  
  
  def initialize(cart_id, user_id)
    @id=cart_id
    @items = []
    @visable=false
    @shipping = 0
    @shipping_type = 0
    @user_id=user_id
  end

  def persisted?
    return true
  end
  
  def item_with_largest_price
    puts("************************ item_with_largest_price First item  ***********************")

    puts(@items[0].inspect)
    puts("************************ *********************************** ***********************")
        
    begin
      @found_item =  @items.max_by do |element|
        element.product.unit_price 
      end 
 
    rescue
      
    end
    puts("************************ item_with_largest_price found item  ***********************")
    puts(@found_item.inspect)
    puts("************************ *********************************** ***********************")
    return @found_item
  end
  
  def save
    saved_cart = self.dup
    saved_cart_items = self.items.dup
   
    Rails.cache.write(self.id, saved_cart, expires_in: 24.hours)  
    Rails.cache.write(self.id+"items",saved_cart_items,expires_in: 24.hours)
  end
 
  def delete
    Rails.cache.delete(self.id)
    Rails.cache.delete(self.id+"items")
  end
 
  def self.get_cart(cart_object_id, user_id)
    puts("cart initialized with id:#{cart_object_id}")
    @cart_object = Rails.cache.fetch(cart_object_id, expires_in: 24.hours) {Cart.new(cart_object_id, user_id)}
    @cart_items  = Rails.cache.fetch(cart_object_id+"items", expires_in: 24.hours) {[]}
   
    @cart=@cart_object.dup  
    @cart.items.replace (@cart_items.dup) rescue []
   
   
    #   puts("Before: #{cart_object_id}")
    #   begin 
    #     @cart_object = ObjectSpace._id2ref(cart_object_id)
    #    puts("cart_object.id #{@cart_object.id}")
    #    puts("cart_object.class #{@cart_object.class == Cart}")
    #
    #     if not @cart_object.class.to_s == "Cart" then
    #       @cart_object = Cart.new
    #     end
    #   rescue
    #     @cart_object = Cart.new
    #   end
    #      puts("After: #{@cart_object.id}")

    return @cart
   
  end
 
  #  def add_product(inventory_item)
  #    @items << inventory_item
  # end

  def add_product(product, product_detail, quantity)
    
    current_item = @items.find {|item| item.product_detail.id == product_detail.id}
   

    if current_item.blank? then
      current_item = CartItem.new(product,product_detail, quantity)
           
      @items << current_item

      if quantity.to_i  > product_detail.units_in_stock then
        current_item.quantity = product_detail.units_in_stock
        self.save
        raise("Exceeded inventory.")
      end
    else
      projected_quantity = current_item.quantity + quantity.to_i
      current_item.increment_quantity(quantity.to_i)
      if projected_quantity  > product_detail.units_in_stock then
        current_item.quantity = product_detail.units_in_stock
        self.save
        raise("Exceeded inventory.")
      end
    end

    self.save
    puts("current_item=> #{current_item.inspect}")
    return(current_item)
    
  end

  def total_items
    @items.sum { |item| item.quantity }
  end

  def total_price
    @items.sum { |item| item.price }

    #  @items.sum { |item| item.price } + (@shipping ||= 0)
    #    @items.sum { |item| item.price } + (self.calc_shipping ||= 0)

  end

  def calc_store_wide_sale
    start_date = Date.parse Settings.store_wide_sale_start
    end_date = Date.parse Settings.store_wide_sale_end

    
   return total_price * (Settings.store_wide_sale.to_s.to_f/100) if (Settings.store_wide_sale.to_s.to_f > 0 and start_date <= Date.today and end_date >= Date.today)
   0
  end
  
  
  def grand_total_price(state_local="")
    
    
    if state_local.to_s=="NJ" then
      total_price + calc_shipping[shipping_type].to_f + calc_tax - coupon_value = calc_store_wide_sale
    else 
      total_price + calc_shipping[shipping_type].to_f  - coupon_value = calc_store_wide_sale
    end
  end
  
  def calc_tax 
    @items.sum { |item| item.tax(0.07) }
    # total_price * 0.07
  end
  
  def shipping_type
    @shipping_type || 0
  end
  
  def shipping_type=(type=0)
    @shipping_type=type
  end

  def price_in_cents
    (self.grand_total_price*100).round
  end

  def shipping_cost
    (@shipping ||= 0)
  end

  def set_shipping(shipping_cost)
    @shipping=shipping_cost
  end

  def calc_shipping
   
    case total_price
    when 0..49.99
      Settings.shipping_level_1.split(",") rescue [5,10,15,0]
    when 50..99.99
      Settings.shipping_level_2.split(",") rescue [7,15,20,0]
    when 100..149.99
      Settings.shipping_level_3.split(",") rescue [10,17,22,0]
    when 150..1999.99
      Settings.shipping_level_4.split(",") rescue  [0,20,25,0]
    else
      [0,0,0,0]
    end
  end


  def id=(identifier)
    @id= identifier
    save
  end

  def items=(items)
    @items.replace(items.dup)
    save
  end

  def coupon_code=(coupon_code)
    @coupon_code=coupon_code
  end
  
  def coupon_code
    return @coupon_code
  end
  
  #  def self.model_name
  #    "Cart"
  #  end
  #  

  def [](code)
    return eval("@" + code.to_s)
  end
  
  def coupon_valid?
    @user=User.find_by_id(@user_id)
    
    @coupon=Coupon.find_coupon(@coupon_code)
    
    return false if(@user.blank?)
    return false if(@coupon.blank?)
    
    return false if((@user.coupon_usages.where(coupon_id: @coupon.id).length > 0) and !!@coupon.one_time_only )
    
    return true
  end
  
  def coupon_description 
    @user=User.find_by_id(@user_id)
    
    @coupon=Coupon.find_coupon(@coupon_code)
    
    return "" if @coupon_code.blank?
    
    if @coupon.blank? then 
      return_value =  "<div style='color:red;'>INVALID COUPON CODE!!</div>".html_safe
    else 
      if coupon_valid? then
        largest_valued_item_name = (!!@coupon.only_most_expensive_item ? " on " + item_with_largest_price.product.product_name : "") rescue "n/a"
        return_value =  @coupon.description + largest_valued_item_name
      else
        return_value =  "<div style='color:red;'>COUPON CODE ALREADY USED!!</div>".html_safe
      end
 
      return return_value 
   
    end
  end
 
  def coupon_type 
    @coupon=Coupon.find_coupon(@coupon_code)
    
    if not @coupon.blank? then
      return  @coupon.type if coupon_valid?
    else 
      return "<div style='color:red;'>INVALID COUPON CODE!!</div>".html_safe
    end
  end
  
  
  def calc_total_on_product(collection_name, coupon_value)
     total_discount = 0
     @items.each_with_index do |the_item, item_index|
        puts("     ++++++++++++++++ +++++++++++++++ +++++++++++++++++ ")
        puts("")
        puts("the_item.product.id: #{the_item.product.id}")
        puts("the_item.product.category_list: #{the_item.product.category_list}")
        puts("Collection_name: #{collection_name}")
             
         if the_item.product.category_list.to_a.include?(collection_name) then
            puts("item #{the_item.product.id} is in collection #{collection_name}.")
            total_discount = total_discount + (the_item.product.msrp.to_s.to_f* (coupon_value.to_f/100))
          end
          
        puts("    ++++++++++++++++ +++++++++++++++ +++++++++++++++++ ")

      end
      return total_discount
  end
  
  def special_calc(coupon)
    @coupon = coupon
    total_discount = 0.0
    coupon_list = @coupon.coupon_calc.split(";")
    puts("--------------- --------------- ---------------- ---------------- ")
    puts("coupon_list: #{coupon_list.inspect}, count:#{coupon_list.length} ") 
    # for coupon_index in 0..coupon_list.length do
    coupon_list.to_a.each_with_index do |coupon_item,coupon_index|
      coupon_item_list = coupon_item.split(":")
      collection_name = coupon_item_list[0]
      coupon_value = coupon_item_list[1]

      puts("--------------- --------------- ---------------- ---------------- ")
      puts("#{coupon_index}: coupon_value #{coupon_value}, coupon_item: #{coupon_item.inspect}, collection_name: #{collection_name} ")
     
        
       @items.each_with_index do |the_item, item_index|
        puts("     ++++++++++++++++ +++++++++++++++ +++++++++++++++++ ")
        puts("")
        puts("the_item.product.id: #{the_item.product.id}")
        puts("the_item.product.category_list: #{the_item.product.category_list}")
        puts("Collection_name: #{collection_name}")
             
         if the_item.product.category_list.to_a.include?(collection_name) then
            puts("item #{the_item.product.id} is in collection #{collection_name}.")
            puts("the_item.product.msrp.to_f* (coupon_value.to_f/100): #{the_item.product.msrp.to_f* (coupon_value.to_f/100)}")
          
            total_discount = total_discount + (the_item.product.msrp.to_f* (coupon_value.to_f/100))
          end
          
        puts("    ++++++++++++++++ +++++++++++++++ +++++++++++++++++ ")

      end
      
      puts("--------------- --------------- ---------------- ---------------- ")

    end
    puts("total_discount: #{total_discount}")
    return total_discount
  end
  
  def coupon_value
    @coupon=Coupon.find_coupon(@coupon_code)
    
    return 0 if @coupon.blank? 
    
    return 0 if(not coupon_valid?)
    
      
   
    puts("coupon type: '#{@coupon.coupon_type}' total price: #{total_price}")

    case @coupon.coupon_type
    when 1 # $$$ amount off
      if total_price > @coupon.min_amount then
        return @coupon.value
      else
        return 0
      end
    when 2 # %%% amount off 
      if total_price > @coupon.min_amount then
        if !!@coupon.only_most_expensive_item then
          puts(item_with_largest_price.inspect)
          return  item_with_largest_price.product.msrp * (@coupon.value/100)
        else        
          return total_price * (@coupon.value/100)
        end
      else
        return 0
      end
    when 3  # 000 Shipping credit
      return @coupon.value
    when 4  # 000 Free Shipping
      puts("@shipping_type: #{@shipping_type}, calc_shipping[@shipping_type]: #{calc_shipping[@shipping_type]} ")
      return calc_shipping[@shipping_type].to_f
    when 5
      
      return special_calc(@coupon) 
      
    else
      return 0
    end rescue return 0
       
  end
  
  
  def hide
    @visable=false
  end

  def show
    @visable=true
  end

  def visable
    @visable
  end

  def standard_checkout(return_url, success_url)

    values = {
      business: 'sales@squirtinibikini.com',
      cmd: '_cart',
      upload: 1,
      return: success_url,
      cancel: return_url,
      rm: 2,
      notify_url: success_url,
      handling_cart: calc_shipping,
      invoice: id
    }
  

    items.each_with_index do |item, index|
      values.merge!({
          "amount_#{index+1}" => item.product.price,
          "item_name_#{index+1}" => item.title,
          "item_number_#{index+1}" => item.id,
          "quantity_#{index+1}" => item.quantity
        })
    end
    "https://sandbox.paypal.com/cgi-bin/webscr?" + values.to_query
  end



end
