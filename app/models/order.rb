# frozen_string_literal: true

class ValidateCard < ActiveModel::Validator
  def validate(record)
    if record.express_token.blank?
      unless record.credit_card.valid?
        record.credit_card.errors.full_messages.each do |message|
          record.errors.add :base, message
          #  record.errors.add_to_base message
        end
      end
    end
  end
end

class Order < ActiveRecord::Base
  require 'activemerchant'

  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy

  has_many :coupon_codes, class_name: 'CouponOrders'

  has_many :transactions, class_name: 'OrderTransaction'

  attr_accessor :cc_number, :cc_verification, :cc_expires, :nonce

  validates_presence_of :ship_first_name, :ship_last_name, :ship_street_1, :ship_city, :ship_state, :ship_zip,
                        :bill_first_name, :bill_last_name, :bill_street_1, :bill_city, :bill_state, :bill_zip

  validates_presence_of :credit_card_type, if: :not_using_square?
  # ,
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

  CC_TYPES = [
    %w[Visa visa],
    %w[MasterCard master],
    %w[Discover discover],
    ['American Express', 'american_express']
  ].freeze

  CC_STATES = [
    %w[Alabama AL],
    %w[Alaska AK],
    %w[Arizona AZ],
    %w[Arkansas AR],
    %w[California CA],
    %w[Colorado CO],
    %w[Connecticut CT],
    %w[Delaware DE],
    %w[Florida FL],
    %w[Georgia GA],
    %w[Hawaii HI],
    %w[Idaho ID],
    %w[Illinois IL],
    %w[Indiana IN],
    %w[Iowa IA],
    %w[Kansas KS],
    %w[Kentucky KY],
    %w[Louisiana LA],
    %w[Maine ME],
    %w[Maryland MD],
    %w[Massachusetts MA],
    %w[Michigan MI],
    %w[Minnesota MN],
    %w[Mississippi MS],
    %w[Missouri MO],
    %w[Montana MT],
    %w[Nebraska NE],
    %w[Nevada NV],
    ['New Hampshire', 'NH'],
    ['New Jersey', 'NJ'],
    ['New Mexico', 'NM'],
    ['New York', 'NY'],
    ['North Carolina', 'NC'],
    ['North Dakota', 'ND'],
    %w[Ohio OH],
    %w[Oklahoma OK],
    %w[Oregon OR],
    %w[Pennsylvania PA],
    ['Rhode Island', 'RI'],
    ['South Carolina', 'SC'],
    ['South Dakota', 'SD'],
    %w[Tennessee TN],
    %w[Texas TX],
    %w[Utah UT],
    %w[Vermont VT],
    %w[Virginia VA],
    %w[Washington WA],
    ['West Virginia', 'WV'],
    %w[Wisconsin WI],
    %w[Wyoming WY]
  ].freeze

  SHIPPING_TYPES = ['Ground', '2 Day', 'Next Day', 'Pick Up Store'].freeze

  before_save :check_double_purchase

  def paid_with_card?
    puts("express_token.blank?:  #{express_token.blank?}")
    (credit_card_type != 'PayPalExpress') && nonce.blank?
  end

  def not_using_square?
    nonce.blank?
  end

  def generate_order_items(cart)
    cart.items.each do |item|
      li = LineItem.from_cart_item(item)
    end
  end

  def check_double_purchase
    current_user = user

    last_user_purchase = (begin
                                current_user.orders.last.created_at
                              rescue StandardError
                                (DateTime.now - 60.seconds)
                              end)

    if (last_user_purchase >= (DateTime.now - 30.seconds)) && (current_user.orders > 0)

      # save fails becuase usesr purchased within the past 30 seconds
      errors.add :base, 'Your order is being processed.  Please wait at least 30 seconds between purchases'
      return false
    end

    return true
  end

  def shipped_via
    SHIPPING_TYPES[shipping_method]
  end

  def reduce_inventory(host)
    order_items.each do |item|
      item.product_detail.reduce_inventory(item.quantity, host)
    end
  end

  def add_line_items_from_cart(cart, _host)
    cart.items.each do |item|
      li = OrderItem.from_cart_item(item)
      #      if (not li.product_detail.nil?) then
      #        li.product_detail.reduce_inventory(item.quantity, host)
      #      end
      order_items << li unless li.nil?
    end

    #  self.shipping_price= cart.shipping_cost
  end

  def purchase(cart)
    @cart = cart
    puts("nonce: #{nonce}")

    if !nonce.blank?

      transaction_api = SquareConnect::TransactionApi.new

      amount = price_in_cents
      request_body = {
        card_nonce: nonce,
        amount_money: {
          amount: amount,
          currency: 'USD'
        },
        idempotency_key: SecureRandom.uuid
      }

      # The SDK throws an exception if a Connect endpoint responds with anything besides 200 (success).
      # This block catches any exceptions that occur from the request.
      SquareConnect::Configuration.default.logger = Rails.logger

      locationApi = SquareConnect::LocationApi.new
      locations = locationApi.list_locations(Settings.gateway_access_token)

      begin
        response = transaction_api.charge(Settings.gateway_access_token, locations.locations[0].id, request_body)

        puts(response.inspect)
        begin
              puts(response[:transaction].inspect)
            rescue StandardError
              "don't work"
            end
        begin
              puts(response.transaction.inspect)
            rescue StandardError
              "don't work"
            end

        success = true
        transactions.create!(action: 'purchase', amount: price_in_cents, success: success, message: 'This transaction has been approved', authorization: response.transaction.id, params: response)
      rescue SquareConnect::ApiError => e
        puts 'Error encountered while charging card:'
        puts e.message
        puts e.message.inspect
        puts eval(e.message).class

        begin
              puts "e.message.code : #{eval(e.message)[:code]}"
            rescue StandardError
              'none'
            end
        begin
              puts "e.message.response_body.detail : #{eval(e.message)[:response_body]}"
            rescue StandardError
              'none'
            end
        success = false

        error_message_json = JSON.parse(eval(e.message)[:response_body])
        error_message = 'Tranaction Failed' + ' [' + error_message_json['errors'][0]['category'] + '] : ' + error_message_json['errors'][0]['detail']

        errors.add :base, error_message

        transactions.create!(action: 'purchase', amount: price_in_cents, success: success, message: error_message, params: e.message)
      end

      #  test = ":response_body=>\"{\\\"errors\\\":[{\\\"category\\\":\\\"PAYMENT_METHOD_ERROR\\\",\\\"code\\\":\\\"CARD_DECLINED\\\",\\\"detail\\\":\\\"Card declined.\\\"}]}\"}"

      #    data = {
      #      amount: amount,
      #      user: {
      #        name: params[:name],
      #        street_address_1: params[:street_address_1],
      #        street_address_2: params[:street_address_2],
      #        state: params[:state],
      #        zip: params[:zip],
      #        city: params[:city]
      #      },
      #      card: resp.transaction.tenders[0].card_details.card
      #    }
      #
      #    # send receipt email to user
      #    ReceiptMailer.charge_email(params[:email],data).deliver_now if Rails.env == "development"
      #

    else
      if express_token.blank?
        gateway = Order.get_gateway
        response = gateway.purchase(price_in_cents, credit_card, purchase_options)

      else
        gateway = Order.get_express_gateway
        response = gateway.purchase(price_in_cents, express_purchase_options)

      end

      transactions.create!(action: 'purchase', amount: price_in_cents, response: response)

      unless response.success?
        errors.add :base, response.message

        # errors.add_to_base(response.message)
      end
      success = response.success?

    end

    # cart.update_attribute(:purchased_at, Time.now) if response.success?

    success
  end

  def self.get_express_gateway
    @gateway_login = Settings.express_gateway_login

    if !@gateway_login.blank?
      puts('Paypal Express Gatway Activated')

      gateway = ActiveMerchant::Billing::PaypalExpressGateway.new(
        login: Settings.express_gateway_login,
        password: Settings.express_gateway_password,
        signature: Settings.express_gateway_signature
      )
    else
      gateway = ::EXPRESS_GATEWAY
    end

    gateway
  end

  def self.get_gateway
    @gateway_signature = Settings.gateway_signature
    @gateway_login = Settings.gateway_login

    if @gateway_login.blank?
      puts("'#{@gateway_login}' Default Gatway Activated")
      gateway = GATEWAY
    else

      if @gateway_signature.blank?
        puts('Application Defined Gatway Activated')

        GATEWAY.options[:login] = Settings.gateway_login
        GATEWAY.options[:password] = Settings.gateway_password

        gateway = GATEWAY

      else
        puts('Paypal Gateway Activated')
        gateway = ActiveMerchant::Billing::PaypalGateway.new(
          login: Settings.gateway_login,
          password: Settings.gateway_password,
          signature: Settings.gateway_signature
        )
      end
    end
  end

  def price_in_cents
    (grand_total_price * 100).round
  end

  def full_shipping_name
    ship_first_name.to_s + ' ' + ship_last_name.to_s
  end

  def full_billing_name
    bill_first_name.to_s + ' ' + bill_last_name.to_s
  end

  def full_shipping_street
    ship_street_1.to_s + ' ' + ship_street_2.to_s
  end

  def full_billing_street
    bill_street_1.to_s + ' ' + bill_street_2.to_s
  end

  def total_price
    order_items.sum(:price)
  end

  def full_tax
    if bill_state == 'NJ'
      sales_tax
    else
      0
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
      details = Order.get_express_gateway.details_for(token)
      puts("Details:  #{details.inspect}")
      self.express_payer_id = details.payer_id
      get_paypal_info(details.params)
      # self.first_name = details.params["first_name"]
      # self.last_name = details.params["last_name"]
    end
  end

  def express_purchase_options
    {
      ip: ip_address,
      token: express_token,
      payer_id: express_payer_id
    }
  end

  def validate_card
    if express_token.blank? && !credit_card.valid?
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

  def get_paypal_info(info)
    self.bill_first_name = info['PayerInfo']['PayerName']['FirstName']
    self.bill_last_name = info['PayerInfo']['PayerName']['LastName']
    self.bill_street_1 = info['PayerInfo']['Address']['Street1'] || ''.dup
    self.bill_street_2 = info['PayerInfo']['Address']['Street2'] || ''.dup
    self.bill_city = info['PayerInfo']['Address']['CityName']
    self.bill_state = info['PayerInfo']['Address']['StateOrProvince']
    self.bill_zip = info['PayerInfo']['Address']['PostalCode']

    self.ship_first_name = info['first_name']
    self.ship_last_name = info['last_name']
    self.ship_street_1 = info['PaymentDetails']['ShipToAddress']['Street1'] || ''.dup
    self.ship_street_2 = info['PaymentDetails']['ShipToAddress']['Street2'] || ''.dup
    self.ship_city = info['PaymentDetails']['ShipToAddress']['CityName']
    self.ship_state = info['PaymentDetails']['ShipToAddress']['StateOrProvince']
    self.ship_zip = info['PaymentDetails']['ShipToAddress']['PostalCode']
  end

  def purchase_options
    {
      ip: ip_address,
      order_id: id,
      email: user.name,
      billing_address: {
        name: bill_first_name + ' ' + bill_last_name,
        address1: bill_street_1 + ' ' + bill_street_2,
        city: bill_city,
        state: bill_state,
        country: 'US',
        zip: bill_zip
      },
      shipping_address: {
        name: ship_first_name + ' ' + ship_last_name,
        address1: ship_street_1 + ' ' + ship_street_2,
        city: ship_city,
        state: ship_state,
        country: 'US',
        zip: ship_zip
      }
    }
  end
    end
