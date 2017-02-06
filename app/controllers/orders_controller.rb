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

    def empty_cart_no_redirect
          find_cart
          @cart.delete
          session[:cart] = nil
          find_cart
        end
        
    def find_cart
          #  @cart = (session[:cart] ||= Cart.new)
          #user =  User.find_by_id(session[:user_id])

          session[:create]=true
        
          session[:session_id] = request.session_options[:id]
          
          begin
            @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id]) rescue  Rails.cache.write("cart"+session[:session_id],{}, :expires_in => 15.minutes)
          rescue
            cart = Cart.new
          end
          
          puts("@cart in find_cart: #{@cart}")
          
          if not params[:coupon_code].blank? then
            puts("Coupon Code Found")
            @cart.coupon_code = params[:coupon_code]
            @cart.save
          end
    
          #   @cart = Cart.get_cart(session[:cart])
          #    session[:cart] = @cart.id
        end

  def enter_order_square
    
     $hostfull = request.protocol + request.host_with_port

    @user = User.find_by_id(session[:user_id])
    @page_title = "order success"
    @page = Page.find_by_title (@page_title).first

    cart_is_empty = false;
    purchase_success = false;
    error_occured = false;
    
    redirect_controller = :site
    redirect_action = :index
    
     if params[:order].blank? then
      puts("****************** New order from cart ************")
      @order=Order.new(:express_token=>params[:token])
      error_occured=true
    else
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

            empty_cart_no_redirect
            
            redirect_controller = :orders
            redirect_action = :order_success
            puts("****************** Purchase Success  ************")
    
            purchase_success = true              # return
            # format.html {render :action => "order_success"}
          else
            SystemNotifier.purchase_fail_notification(@order, @user, $hostfull).deliver
            error_occured=true
          end
          #  format.html { redirect_to @order, :notice=>"Order was successfully created." }
          #  format.json { render :json=>@order, :status=>:created, :location=>@order }
        else
          error_occured = true
        end
      else
        puts("****************** Cart is empty (redirect to /site/index) ************")
       
        redirect_controller = :site
        redirect_action = :index
      
        # cart_is_empty = true
      end
     end
     
    respond_to do |format|
      if error_occured then
        puts("****************** ERROR OCCURED ************")
        puts("#{@order.errors.inspect}")
        format.html { render action: "enter_order_square", params: params[:order] }
        format.json { render json: @order.errors, status: :unprocessable_entry }
      else

        puts("****************** Redirct occured   ************")
        format.html { redirect_to(controller: redirect_controller, action: redirect_action, id: @order) && return}
      end
   
    end
  end
  
  def enter_order
    
    $hostfull = request.protocol + request.host_with_port

    @user = User.find_by_id(session[:user_id])
    @page_title = "order success"
    @page = Page.find_by_title (@page_title).first

    cart_is_empty = false;
    purchase_success = false;
    error_occured = false;
    
    redirect_controller = :site
    redirect_action = :index
    puts("params.inspect : #{params.inspect}")
    puts("params[:nonce] : #{params[:nonce]}")
    
    if params[:order].blank? then
      puts("****************** New order from cart ************")
      @order=Order.new(:express_token=>params[:token])
      error_occured=true
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
      @order.coupon_code = @cart.coupon_code

      @order.store_wide_sale = @cart.calc_store_wide_sale
      
      @order.cc_expires = Date.new(params[:order]["cc_expires(1i)"].to_i, params[:order]["cc_expires(2i)"].to_i, params[:order]["cc_expires(2i)"].to_i) rescue nil
      @order.cc_number = params[:order][:cc_number] || ""
      @order.cc_verification = params[:order][:cc_verification] || ""
      @order.nonce = params[:nonce] || ""
      
      puts("-=-=-=-=-=-=-=-=-=-=-=-=-=->>>> #{@order.inspect}")

      
       if params[:save_billing_addresses] == "1" then
        @user.user_attribute.billing_address  = @order.bill_street_1 
        @user.user_attribute.billing_city =  @order.bill_city
        @user.user_attribute.billing_state = @order.bill_state 
        @user.user_attribute.billing_zip_code =  @order.bill_zip
        @user.save
        @user.user_attribute.save
      end
      if params[:save_shipping_addresses] == "1" then
        @user.user_attribute.shipping_address = @order.ship_street_1
        @user.user_attribute.shipping_city = @order.ship_city 
        @user.user_attribute.shipping_state  = @order.ship_state 
        @user.user_attribute.shipping_zip_code = @order.ship_zip
        @user.save
        @user.user_attribute.save
      end
      
      
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

            empty_cart_no_redirect
            
            redirect_controller = :orders
            redirect_action = :order_success
            puts("****************** Purchase Success  ************")
    
            purchase_success = true              # return
            # format.html {render :action => "order_success"}
          else
            SystemNotifier.purchase_fail_notification(@order, @user, $hostfull).deliver
            error_occured=true
          end
          #  format.html { redirect_to @order, :notice=>"Order was successfully created." }
          #  format.json { render :json=>@order, :status=>:created, :location=>@order }
        else
          error_occured = true
        end
      else
        puts("****************** Cart is empty (redirect to /site/index) ************")
       
        redirect_controller = :site
        redirect_action = :index
      
        # cart_is_empty = true
      end
    end 
  
    respond_to do |format|
      if error_occured then
        puts("****************** ERROR OCCURED ************")
        puts("#{@order.errors.inspect}")
        format.html { render action: "enter_order", params: params[:order] }
        format.json { render json: @order.errors, status: :unprocessable_entry }
      else

        puts("****************** Redirct occured   ************")
        format.html { redirect_to(controller: redirect_controller, action: redirect_action, id: @order) && return}
      end
   
    end
  end

  def order_success 
    @page_title = "order success"
    @order = Order.find(params[:id])
    @user = User.find_by_id(session[:user_id])
    @page = Page.where(:title=>@page_title).first
   #  @page = Page.find_by_title (@page_title).first
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
    
    render  partial: "invoice_report.html", layout: "default_pdf.html"
  end
  
  def resend_invoice
    @hostfull = request.protocol + request.host_with_port
    @user = User.find_by_id(session[:user_id])
    @order = Order.find_by_id(params[:order_id])
    
    if  not Settings.order_notification=="true" then
      UserNotifier.order_notification(@order, @order.user, @hostfull).deliver
    else
      UserNotifier.order_notification_as_invoice(@order, @order.user, @hostfull).deliver
    end            
   
    flash[:notice] = "Invoice receipt resent to user #{@order.user.full_name}."
    
    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
    end
    
    # redirect_back_or_default(request.referer)

  end

  def user_orders
    @user = User.find_by_id(session[:user_id])
    @orders = @user.orders.joins(:transactions).where(order_transactions: {success: true})
  
    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @orders} 
    end  end
  
  
  
  def user_order_table
    @objects = current_objects_user(params)
    @total_objects = total_objects_user(params)
    render :layout => false
  end
  
  
  def order_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render :layout => false
  end
  
  def express_purchase
    puts("Paypal Epress Gateway Activated")
    @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id])

    gateway = Order.get_express_gateway
    
    puts("request.remote_ip #{request.remote_ip.class}")

    
    response = gateway.setup_purchase(@cart.grand_total_price("NJ"),
      :ip                => request.remote_ip,
      :return_url        => enter_order_orders_url,
      :cancel_return_url => site_check_out_url
    )
    puts("response.token: #{response.token}")
    puts("response: #{response.inspect}")
      
    redirect_to gateway.redirect_url_for(response.token)
  end
  

  def express
    response = EXPRESS_GATEWAY.setup_purchase(current_cart.build_order.price_in_cents,
      :ip                => request.remote_ip,
      :return_url        => new_order_url,
      :cancel_return_url => products_url
    )
    redirect_to EXPRESS_GATEWAY.redirect_url_for(response.token)
  end

  
  def product_list_report 
    
    @user = User.find(session[:user_id])
         
    @start_date = Date.parse(Settings.report_start_date).to_s
    @end_date = Date.parse(Settings.report_end_date).to_s
    
    @orders_ids = Order.joins(:transactions).where(:order_transactions=>{:success=>true}).where("orders.created_at >= '#{@start_date}' and orders.created_at <= '#{Date.parse(@end_date).to_s}'").select("id").collect(&:id)
   # @order_items = OrderItem.where(:id=>@orders_ids)
    @order_items = OrderItem.where(:id=>@orders_ids).select(:product_detail_id, :product_id, "SUM(quantity) as sum_product_count", "SUM(price) as sum_price").group(:product_detail_id).order("sum_product_count DESC")
    
    
  render "product_list_report.html", layout: "default_pdf.html"

  end

  private
    

  def current_objects_user(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = Order.joins(user: [:user_attribute]).joins(:transactions).page(current_page).per(params[:length]).order("#{datatable_columns_user(params[:order]["0"][:column])} #{params[:order]["0"][:dir] || "DESC"}").where(conditions_user(params))
  end
  

  def total_objects_user(params={})
    @total_objects = Order.joins(user: [:user_attribute]).joins(:transactions).where(conditions_user(params)).count()
  end

  def datatable_columns_user(column_id)
    puts(column_id)
    case column_id.to_i
    when 0
      return "`orders`.`id`"
    when 1
      return "`orders`.`created_at`"
    when 2
      return "`orders`.`shipped_date`"
    when 3
      return "`order_transactions`.`amount`"
    else
      return "`order_transactions`.`success`"
    end
  end

      
  def conditions_user(params={})
    @user = User.find_by_id(session[:user_id])

    conditions = ["orders.user_id = #{@user.id}"]
   
    conditions << "(orders.id LIKE '%#{params[:search][:value]}%' OR
          user_attributes.first_name LIKE '%#{params[:search][:value]}%' OR 
          user_attributes.last_name LIKE '%#{params[:search][:value]}%' OR 
          order_transactions.amount LIKE '%#{params[:search][:value]}%' OR 
          orders.created_at LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
    
    
  end
  
  
  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = Order.joins(user: [:user_attribute]).joins(:transactions).page(current_page).per(params[:length]).order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir] || "DESC"}").where(conditions(params))
  end
  

  def total_objects(params={})
    @total_objects = Order.joins(user: [:user_attribute]).joins(:transactions).where(conditions(params)).count()
  end

  def datatable_columns(column_id)
    puts(column_id)
    case column_id.to_i
    when 0
      return "`orders`.`id`"
    when 1
      return "`user_attributes`.`first_name`"
    when 2
      return "`orders`.`created_at`"
    when 3
      return "`orders`.`shipped_date`"
    when 4
      return "`order_transactions`.`amount`"
    else
      return "`order_transactions`.`success`"
    end
  end

      
  def conditions(params={})
    
    conditions = []
   
    conditions << "(orders.id LIKE '%#{params[:search][:value]}%' OR
          user_attributes.first_name LIKE '%#{params[:search][:value]}%' OR 
          user_attributes.last_name LIKE '%#{params[:search][:value]}%' OR 
          order_transactions.amount LIKE '%#{params[:search][:value]}%' OR 
          orders.created_at LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
    
    
  end
  
  def order_params
    params[:order].permit("user_id", "nonce", "credit_card_type", "credit_card_expires", "ip_address", "shipped", "shipped_date", "ship_first_name", "ship_last_name", "ship_street_1", "ship_street_2", "ship_city", "ship_state", "ship_zip", "bill_first_name", "bill_last_name", "bill_street_1", "bill_street_2", "bill_city", "bill_state", "bill_zip", "created_at", "updated_at", "shipping_cost", "sales_tax", "shipping_method", "coupon_description", "coupon_value", "store_wide_sale","cc_number", "cc_verification", "cc_expires(1i)", "cc_expires(2i)", "cc_expires(3i)", "express_token","bill_phone", "ship_phone")
  end
end
