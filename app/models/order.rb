class ValidateCard < ActiveModel::Validator
  def validate(record)
    unless !record.express_token.blank? 
      unless record.credit_card.valid?
      record.credit_card.errors.full_messages.each do |message|
        record.errors.add :base, message
        #  record.errors.add_to_base message
        end
      end
    end
  end
    

  private
  def some_complex_logic
    # ...
  end
end





class Order < ActiveRecord::Base
  
  require "activemerchant"
  
  belongs_to :user
  has_many :order_items , dependent: :destroy

  has_many :coupon_codes, class_name: "CouponOrders"
  
  has_many :transactions, class_name: "OrderTransaction"

  attr_accessor :cc_number, :cc_verification, :cc_expires
 
   validates_presence_of :ship_first_name, :ship_last_name, :ship_street_1, :ship_city, :ship_state, :ship_zip,
    :bill_first_name, :bill_last_name, :bill_street_1, :bill_city, :bill_state, :bill_zip, :credit_card_type
  #,
  #  :credit_card_type, :cc_number, :cc_expires, :cc_verification
  #
    
  # validate_on_create :validate_card
  validates_with ValidateCard, on: :create, if: :paid_with_card?
  
#  composed_of :cc_expires, class_name: "Date",
#    mapping: %w(Date to_s),
#    constructor: Proc.new { |item| item },
#    converter: Proc.new { |item| item }

#  composed_of :cc_expires,
#:class_name => 'DateTime',
#:mapping => %w(DateTime to_s),
#:constructor => Proc.new { |date| (date && date.to_date) || Date.today },
#:converter => Proc.new { |value| value.to_s.to_date }

  CC_TYPES =  [
    ["Visa", "visa"],
    ["MasterCard", "master"],
    ["Discover", "discover"],
    ["American Express", "american_express"]
  ].freeze
  
  CC_STATES= [
    [ "Alabama", "AL" ],
    [ "Alaska", "AK" ],
    [ "Arizona", "AZ" ],
    [ "Arkansas", "AR" ],
    [ "California", "CA" ],
    [ "Colorado", "CO" ],
    [ "Connecticut", "CT" ],
    [ "Delaware", "DE" ],
    [ "Florida", "FL" ],
    [ "Georgia", "GA" ],
    [ "Hawaii", "HI" ],
    [ "Idaho", "ID" ],
    [ "Illinois", "IL" ],
    [ "Indiana", "IN" ],
    [ "Iowa", "IA" ],
    [ "Kansas", "KS" ],
    [ "Kentucky", "KY" ],
    [ "Louisiana", "LA" ],
    [ "Maine", "ME" ],
    [ "Maryland", "MD" ],
    [ "Massachusetts", "MA" ],
    [ "Michigan", "MI" ],
    [ "Minnesota", "MN" ],
    [ "Mississippi", "MS" ],
    [ "Missouri", "MO" ],
    [ "Montana", "MT" ],
    [ "Nebraska", "NE" ],
    [ "Nevada", "NV" ],
    [ "New Hampshire", "NH" ],
    [ "New Jersey", "NJ" ],
    [ "New Mexico", "NM" ],
    [ "New York", "NY" ],
    [ "North Carolina", "NC" ],
    [ "North Dakota", "ND" ],
    [ "Ohio", "OH" ],
    [ "Oklahoma", "OK" ],
    [ "Oregon", "OR" ],
    [ "Pennsylvania", "PA" ],
    [ "Rhode Island", "RI" ],
    [ "South Carolina", "SC" ],
    [ "South Dakota", "SD" ],
    [ "Tennessee", "TN" ],
    [ "Texas", "TX" ],
    [ "Utah", "UT" ],
    [ "Vermont", "VT" ],
    [ "Virginia", "VA" ],
    [ "Washington", "WA" ],
    [ "West Virginia", "WV" ],
    [ "Wisconsin", "WI" ],
    [ "Wyoming", "WY" ]
  ].freeze
    
  SHIPPING_TYPES= ["Ground" , "2 Day", "Next Day", "Pick Up Store"].freeze
    
    
    def paid_with_card? 
      puts("express_token.blank?:  #{express_token.blank?}")
      credit_card_type != "PayPalExpress"
    end
 
  def generate_order_items(cart)
    cart.items.each do |item|
      li = LineItem.from_cart_item(item)

    end
  
  end

  def shipped_via
    return SHIPPING_TYPES[shipping_method]
  end

  def reduce_inventory(host)
    order_items.each do |item|
      if (not item.product_detail.nil?) then
        item.product_detail.reduce_inventory(item.quantity, host)
      end
    end
  end
 
  def add_line_items_from_cart(cart, host)
    cart.items.each do |item|
      li = OrderItem.from_cart_item(item)
      #      if (not li.product_detail.nil?) then
      #        li.product_detail.reduce_inventory(item.quantity, host)
      #      end
      order_items << li if (not li.nil?)
    end
  
    #  self.shipping_price= cart.shipping_cost
  end

    def purchase(cart)
    @cart=cart
        
   if express_token.blank?
      gateway = Order.get_gateway
      response = gateway.purchase(price_in_cents, credit_card, purchase_options)
      
   else
      gateway = Order.get_express_gateway
      response = gateway.purchase(price_in_cents, express_purchase_options)

    end
    
    transactions.create!(:action => "purchase", :amount => price_in_cents, :response => response)
    if not response.success? then
        errors.add :base, response.message
        
     # errors.add_to_base(response.message)
    end
   
    # cart.update_attribute(:purchased_at, Time.now) if response.success?
    
    response.success?
  end
  
  def self.get_express_gateway
    
  @gateway_login = Settings.express_gateway_login

  if !@gateway_login.blank? then
      gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
        :login => Settings.express_gateway_login,
        :password => Settings.express_gateway_password,
        :signature => Settings.express_gateway_signature
      )
    else
      gateway= ::EXPRESS_GATEWAY
    end
    
    return gateway
  end
  
  
  def self.get_gateway
    
    @gateway_signature = Settings.gateway_signature
    @gateway_login = Settings.gateway_login
    
    if @gateway_login.blank? then
      puts("'#{@gateway_login}' Default Gatway Activated")
      gateway = GATEWAY
    else
    if @gateway_signature.blank? then
        puts("Authorize Net Gatway Activated")

        gateway = ActiveMerchant::Billing::CyberSourceGateway.new(
   
          :login => Settings.gateway_login,
          :password => Settings.gateway_password
        )
      else
        puts("Paypal Gateway Activated")
        gateway = ActiveMerchant::Billing::PaypalGateway.new(
          :login => Settings.gateway_login,
          :password => Settings.gateway_password,
          :signature => Settings.gateway_signature
        )
      end
    end
      
  end
  
  def price_in_cents
    (grand_total_price*100).round
  end

  
  def full_shipping_name
    ship_first_name.to_s + " " + ship_last_name.to_s
  end
  
  def full_billing_name
    bill_first_name.to_s + " " + bill_last_name.to_s
  end
  
  def full_shipping_street
    ship_street_1.to_s + " " + ship_street_2.to_s
  end
  
  def full_billing_street
    bill_street_1.to_s + " " + bill_street_2.to_s
  end
  
  
  def total_price
    order_items.sum(:price)
  end
  
  def full_tax
    if bill_state == "NJ" then
      return sales_tax
    else
      return 0
    end
  end
  
  
  def grand_total_price
    (total_price || 0) + (full_tax || 0) + (shipping_cost || 0) - (coupon_value || 0) - (store_wide_sale || 0)
  end
  
  
   # paypal express
  
  def express_token=(token)
    puts("**************** >> token: #{token}")
    write_attribute(:express_token, token)
    if new_record? && !token.blank?
      details = EXPRESS_GATEWAY.details_for(token)
      puts("Details:  #{details.inspect}")
      self.express_payer_id = details.payer_id
      get_paypal_info(details.params)
      # self.first_name = details.params["first_name"]
      # self.last_name = details.params["last_name"]
    end
  end

   
  def express_purchase_options
  {
    :ip => ip_address,
    :token => express_token,
    :payer_id => express_payer_id
  }
end
  
  def validate_card
  if (express_token.blank? and !credit_card.valid?) then
    credit_card.errors.full_messages.each do |message|
      errors.add_to_base message
    end
  end
end
#
#  def validate_card
#    unless credit_card.valid?
#      credit_card.errors.full_messages.each do |message|
#        errors.add_to_base message
#      end
#    end
#  end
  
  def credit_card
    @credit_card ||= ActiveMerchant::Billing::CreditCard.new(
      type: credit_card_type,
      number: cc_number,
      verification_value: cc_verification,
      month: cc_expires.month,
      year: cc_expires.year,
      first_name: bill_first_name,
      last_name: bill_last_name
    ) 
  end
  
  
  private
  
  def get_paypal_info (info)
    self.bill_first_name = info["PayerInfo"]["PayerName"]["FirstName"]
    self.bill_last_name = info["PayerInfo"]["PayerName"]["LastName"]
    self.bill_street_1 = info["PayerInfo"]["Address"]["Street1"] || ""
    self.bill_street_2 = info["PayerInfo"]["Address"]["Street2"] || ""
    self.bill_city = info["PayerInfo"]["Address"]["CityName"]
    self.bill_state = info["PayerInfo"]["Address"]["StateOrProvince"]
    self.bill_zip = info["PayerInfo"]["Address"]["PostalCode"]
    
    self.ship_first_name = info["first_name"]
    self.ship_last_name = info["last_name"]
    self.ship_street_1 = info["PaymentDetails"]["ShipToAddress"]["Street1"] || ""
    self.ship_street_2 = info["PaymentDetails"]["ShipToAddress"]["Street2"] || ""
    self.ship_city = info["PaymentDetails"]["ShipToAddress"]["CityName"]
    self.ship_state = info["PaymentDetails"]["ShipToAddress"]["StateOrProvince"]
    self.ship_zip = info["PaymentDetails"]["ShipToAddress"]["PostalCode"]
    
  end
  
  def purchase_options
    {
      ip: ip_address,
      order_id: id,
      email: user.name,
      billing_address: {
        name: bill_first_name + " " + bill_last_name,
        address1: bill_street_1 + " " + bill_street_2,
        city: bill_city,
        state: bill_state,
        country: "US",
        zip: bill_zip
      },
      shipping_address: {
        name: ship_first_name + " " + ship_last_name,
        address1: ship_street_1 + " " + ship_street_2,
        city: ship_city,
        state: ship_state,
        country: "US",
        zip: ship_zip
      }
    }
  end
 
  
end
