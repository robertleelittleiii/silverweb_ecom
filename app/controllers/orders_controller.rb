class OrdersController < ApplicationController
 
  #  include ::SslRequirement if ENV['RAILS_ENV']=="production"

  # ssl_required :enter_order  if ENV['RAILS_ENV']=="production"
  
  before_filter :force_ssl, :only => [:enter_order]

  
  def force_ssl(options = {})
    host = options.delete(:host)
    unless request.ssl? or Rails.env.development?
      redirect_options = {:protocol => 'https://', :status => :moved_permanently}
      redirect_options.merge!(:host => host) if host
      flash.keep
      redirect_to redirect_options and return
    else
      true
    end
  end

  
  # GET /orders
  # GET /orders.json
  def index
    @orders = Order.order("id DESC").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders} 
    end
  end

  # GET /orders/1
  # GET /orders/1.json
  def show
    @order = Order.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order }
    end
  end

  # GET /orders/new
  # GET /orders/new.json
  def new
    @order = Order.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order}
    end
  end

  # GET /orders/1/edit
  def edit
    @order = Order.find(params[:id])
  end

  # POST /orders
  # POST /orders.json
  
  def create
    @order = Order.new(order_params)

    respond_to do |format|
      if @order.save
        format.html { redirect_to @order, notice: "Order was successfully created." }
        format.json { render json: @order, status: :created, location: @order }
      else
        format.html { render action: "new" }
        format.json { render json: @order.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /orders/1
  # PUT /orders/1.json
  def update
    @order = Order.find(params[:id])

    respond_to do |format|
      if @order.update_attributes(order_params)
        format.html { redirect_to @order, notice: "Order was successfully updated."}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @order.errors, status: "unprocessable_entry" }
      end
    end
  end

  # DELETE /orders/1
  # DELETE /orders/1.json
  def destroy
    @order = Order.find(params[:id])
    @order.destroy

    respond_to do |format|
      format.html { redirect_to orders_url }
      format.json { head :ok }
    end
  end
  
  # CREATE_EMPTY_RECORD /orders/1
  # CREATE_EMPTY_RECORD /orders/1.json

  def create_empty_record
    $hostfull=request.protocol + request.host_with_port

    user =  User.find_by_id(session[:user_id])

    @cart=Cart.get_cart("cart"+session[:session_id], user.id)
    
    @order = Order.new
    @order.add_line_items_from_cart(@cart, $hostfull)
    @order.user = User.find_by_id(session[:user_id])
    @order.ip_address = request.remote_ip
    # @order.email = @order.user.name
    @order.save
    
    redirect_to(controller: :orders, action: :edit, id: @order)
  end

  
  
  def enter_order
    $hostfull = request.protocol + request.host_with_port

    @user = User.find_by_id(session[:user_id])
    @page_title = "order success"
    @page = Page.find_by_title (@page_title).first

    
    if params[:order].blank? then
      @order=Order.new
    else
    
      puts("params[cc_expires(1i)]#{params[:order]["cc_expires(1i)"].inspect}")
      puts("params[cc_expires(2i)]#{params[:order]["cc_expires(2i)"].inspect}")
      puts("params[cc_expires(3i)]#{params[:order]["cc_expires(3i)"].inspect}")

      user =  User.find_by_id(session[:user_id])

      @cart=Cart.get_cart("cart"+session[:session_id], user.id)

      @order = Order.new(order_params)
      @order.add_line_items_from_cart(@cart, $hostfull)
      @order.shipping_method = @cart.shipping_type
      @order.sales_tax = @cart.calc_tax 
      @order.shipping_cost = @cart.calc_shipping[@cart.shipping_type]
      @order.user = User.find_by_id(session[:user_id])
      @order.ip_address = request.remote_ip
      @order.coupon_description = @cart.coupon_description
      @order.coupon_value = @cart.coupon_value
      @order.store_wide_sale = @cart.calc_store_wide_sale
      @order.cc_expires = Date.new(params[:order]["cc_expires(1i)"].to_i, params[:order]["cc_expires(2i)"].to_i, params[:order]["cc_expires(2i)"].to_i)
  
      @order.cc_number = params[:order][:cc_number] 
      @order.cc_verification = params[:order][:cc_verification]

      respond_to do |format|
        if @cart.total_price > 0 then
          if @order.save
            if @order.purchase(@cart)
              @order.reduce_inventory($hostfull)
            
              if  not Settings.order_notification then
                UserNotifier.order_notification(@order, @user, $hostfull).deliver
              else
                UserNotifier.order_notification_as_invoice(@order, @user, $hostfull).deliver
              end
            
              #  if there is a coupon, make a record that it was used.
              if not @cart.coupon_code.blank? then
                @coupon = Coupon.where(coupon_code: @cart.coupon_code).first
                @coupon_used = CouponUsage.create(user_id: @user.id, coupon_id: @coupon.id)
                @coupon.save
              end

              empty_cart
              format.html { redirect_to(controller: :orders, action: :order_success, id: @order)}
              # format.html {render :action => "order_success"}
            else
              SystemNotifier.purchase_fail_notification(@order, @user, $hostfull).deliver
              format.html { render action: "enter_order", params: params[:order]}
            end
            #  format.html { redirect_to @order, :notice=>"Order was successfully created." }
            #  format.json { render :json=>@order, :status=>:created, :location=>@order }
          else
            format.html { render action: "enter_order", params: params[:order] }
            format.json { render json: @order.errors, status: :unprocessable_entry }
          end
        else
          format.html {redirect_to(controller: :site, action: :show_page)}
        end
      end 
    end

  end
  
  def order_success 
    @page_title = "order success"
    @order = Order.find(params[:id])
    @user = User.find_by_id(session[:user_id])
    @page = Page.find_by_title (@page_title).first
    @company_name = Settings.company_name
    @company_address = Settings.company_address
    @company_phone = Settings.company_phone
    @company_fax = Settings.company_fax 
  end
  
  def invoice_slip
    @page_title = "order success"

    @order = Order.find(params[:id])
    @user = User.find_by_id(session[:user_id])
    @page = Page.find_by_title (@page_title).first
    @company_name = Settings.company_name
    @company_address = Settings.company_address
    @company_phone = Settings.company_phone
    @company_fax = Settings.company_fax
    
    render partial: "invoice_report.html", layout: false
  end
  
  def resend_invoice
    @hostfull = request.protocol + request.host_with_port
    @user = User.find_by_id(session[:user_id])
    @order = Order.find_by_id(params[:order_id])
    
    if  not Settings.order_notification then
      UserNotifier.order_notification(@order, @order.user, @hostfull).deliver
    else
      UserNotifier.order_notification_as_invoice(@order, @order.user, @hostfull).deliver
    end            
   
    flash[:notice] = "Invoice receipt resent to user #{@order.user.full_name}."
    redirect_back_or_default(request.referer)

  end

  def user_orders
    @user = User.find_by_id(session[:user_id])
    @orders = @user.orders.joins(:transactions).where(order_transactions: {success: true})
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders} 
    end  end
  
  def order_params
    params[:order].permit("user_id", "credit_card_type", "credit_card_expires", "ip_address", "shipped", "shipped_date", "ship_first_name", "ship_last_name", "ship_street_1", "ship_street_2", "ship_city", "ship_state", "ship_zip", "bill_first_name", "bill_last_name", "bill_street_1", "bill_street_2", "bill_city", "bill_state", "bill_zip", "created_at", "updated_at", "shipping_cost", "sales_tax", "shipping_method", "coupon_description", "coupon_value", "store_wide_sale")
  end
  
end
