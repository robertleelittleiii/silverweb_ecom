module SilverwebEcom
  module ControllerExtensions
  
   module MenusControllerExtensions
    
      def self.included(base)
        base.send(:include, InstanceMethods)
        # base.alias_method_chain :new, :my_module
      end

      module InstanceMethods
        
        def update_checkbox_tag
          @menu = Menu.find(params[:id])
          @tag_name=params[:tag_name] || "tag_list"
    
          if @menu.send(@tag_name).include?(params[:field]) then
            @menu.send(@tag_name).remove(params[:field])
          else
            @menu.send(@tag_name).add(params[:field])
          end
    
          @menu.save

          render(nothing: true)

      
        end
        
        def render_category_div
    @menu=Menu.find(params[:id])
    render(partial: "category_div")
  end
  
      end
      
      
    end
    
    module SiteControllerExtensions
    
      def self.included(base)
        base.send(:include, InstanceMethods)
        # base.alias_method_chain :new, :my_module
      end

      module InstanceMethods
        
      
 #       before_filter :find_cart, :except => :empty_cart

        def show_products
          puts("in show products...")
          session[:mainnav_status] = false
          session[:last_catetory] = request.env['REQUEST_URI']
          @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
          @page_info = Page.where(:title => params[:page_name]).first || ""
          puts("---------the page=> #{@page_info.inspect}")
          @products_per_page = Settings.products_per_page.to_i || 8
          @category_id = params[:category_id].to_s.downcase || ""
          @department_id = params[:department_id].to_s.downcase || ""
          @category_children = params[:category_children] || false
          @get_first_submenu = params[:get_first_sub] || false
          @the_page = params[:page] || "1"
    
          @menu = Menu.where(:name=>@category_id).first 
  
          if params[:top_menu] and @get_first_submenu == "true" then
            # puts("top_menu id: #{@menu.menus[0].name}")
            session[:parent_menu_id] = @menu.id rescue 0
            @menu = @menu.menus[0]
            @category_id = @menu.name rescue "n/a"

          end
      
          #@page_name=Menu.find(session[:parent_menu_id]).name rescue ""
          begin 
            if @category_children == "true" then
              @categories =  create_menu_lowest_child_list(@category_id, nil,false) + [@category_id]
              puts("categories: #{@categories.inspect} ")
              @products_list = Product.where(:product_active=>true).tagged_with(@categories, :any=>true, :on=>:category).tagged_with(@department_id, :on=>:department)

            else
              if @category_id.blank? or @department_id.blank? then
                @products_list = Product.where(:product_active=>true)
              else
                @products_list = Product.where(:product_active=>true).tagged_with(@category_id, :on=>:category).tagged_with(@department_id, :on=>:department)
              end
              
            end
         # puts("=------------ product list found ---------------")
          # puts(@products_list.inspect)
          rescue
          #  @products_list = Product.all
          end
    
          @product_ids = @products_list.collect{|prod| prod.id }

          @product_count = @products_list.length

          # @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
          @products = Product.where(:id=>@product_ids).order("product_ranking DESC").order("position ASC").order("created_at DESC").page(params[:page]).per(@products_per_page)
          #    @products = @products.page(params[:page]).per(@products_per_page)

          @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page-1))
    
          @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length

         system_action_template = (Settings.product_list_template_name.blank? ? "show_products" : "show_products-" + Settings.product_list_template_name) rescue "show_products"
         @action_template = params[:template].blank? ? system_action_template :  params[:template]

          
          respond_to do |format|
            format.html { render :action=>@action_template}
            format.xml  { render :xml => @products }
          end
        end
  


        def live_product_search
    
          session[:mainnav_status] = false
          session[:last_catetory] = request.env['REQUEST_URI']
          @page_name=Menu.find(session[:parent_menu_id]).name rescue ""
    
          @products_per_page = Settings.search_products_per_page.to_i || 8
          @category_id = params[:category_id] || ""
          @department_id = params[:department_id] || ""
          @category_children = params[:category_children] || false

      
      
          @search = params[:search]
   
          session[:search] = params[:search].strip if params[:search]
    
          @history = (session[:history] || "[Nothing...]").split(":,:")
     
          if (not @history.include?(params[:search]) and not params[:search].blank?) then
            session[:history] = "" + (session[:history].blank? ? "" : (session[:history] ) ) + (session[:search].blank? ? "" :":,:" + session[:search])    
            @history = (session[:history] || "[Nothing...]").split(":,:")
            @history = @history[1..10] if @history.size > 10
            session[:history] = @history.join(":,:");
          end
     
   

          @products = Product.by_search_term(session[:search])

          # @products = Product.find_products_search(params[:page], session[:search])
    
          @product_count = @products.length

          @products = Kaminari.paginate_array(@products).page(params[:page]).per(@products_per_page)
    
          @product_first = params[:page].blank? ? "1" : (params[:page].to_i*@products_per_page - (@products_per_page - 1))
    
          @product_last = params[:page].blank? ? @products.length : ((params[:page].to_i*@products_per_page) - @products_per_page) + @products.length || @products.length


          if session[:search] and request.xhr?
            render  :action=>"show_products_search"
          else
    
    
            respond_to do |format|
              format.js  { render :action=>"show_products_search"}
              format.html { render :action=>"show_products_search"}
              format.xml  { render :xml => @products }
              format.json { render :json=> @products }
            end
          end
          #    render :nothing => true
        end
  





        def get_sizes_for_color 
    
          @product = Product.find(params[:id]) 

          @product_sizes = @product.product_details.select("distinct `size`, `units_in_stock`").where("`color` = '#{params[:color]}'").where(:sku_active=>true)  || [{:size=>'N/S', :units_in_stock=>"0"}] rescue [{:size=>'N/S', :units_in_stock=>"0"}]
          #    @product_sizes = @product.product_details.select("distinct `size`, `units_in_stock`").where("`color` = '#{params[:color]}'")  || [{:size=>'n/a', :units_in_stock=>"0"}]
          # .map(&:to_i).sort
          @product_size_array = @product_sizes.map{ |f| f.size }
          render :partial=>"sizes_list.html"
        end
  
        def product_detail

          session[:mainnav_status] = false
          if params[:id].blank? then
            @product = Product.first
          else
            @product = Product.find(params[:id]) 
          end
    
          if params[:next] then
            @product = @product.next_in_collection
            puts "=======NEXT========"
          end
    
          if params[:prev] then
            @product = @product.previous_in_collection
            puts "=======PREV======="

          end
    
          session[:parent_menu_id] = 0
          
          @page_template = (not @product.custom_layout.blank?) ? "product_detail-" + @product.custom_layout : ("product_detail-" + Settings.product_template_name rescue "product_detail") rescue "product_detail" 
          
          
          @java_script_custom = (@page_template != "product_detail")  ? @page_template + ".js" : "" rescue ""
          @style_sheet_custom = (@page_template != "product_detail") ? @page_template + ".css" : "" rescue ""
          @page_name = @product.product_name rescue "'Home' not found!!"
    
          @collection_product_list = Product.all()
          @pictures = @product.pictures.where(:active_flag=>true)
    
          @sizing_page = Page.find_by_title(@product.sheet_name + " Sizing") rescue ""
          @care_page = Page.find_by_title(@product.sheet_name + " Care") rescue ""

          @product_details = @product.product_details
          @product_colors = @product_details.group(:color).where(:sku_active=>true) || [{:size=>'N/C'}] rescue [{:size=>'N/C'}]
          @product_sizes = @product_details.select("distinct `size`, `units_in_stock`").where("`color` = '#{@product_colors[0].color}'").where(:sku_active=>true)  || [{:size=>'N/S', :units_in_stock=>"0"}] rescue [{:size=>'N/S', :units_in_stock=>"0"}]
          @product_size_array = @product_sizes.map{ |f| f.size }
    
    
          respond_to do |format|
            format.html { render :action=>@page_template} # show.html.erb
            format.xml  { render :xml => @page }
          end
    
        end
  
        #
        #
        #check out
        #
        #
        def check_out
          find_cart

          @shipping_methods = [["Ground",0] , ["2 Day",1], ["Next Day",2], ["Pick Up Store",3]]
          if @cart.items.empty?
            redirect_to(:controller => "site", :action => "index")
          else
            #@cart.hide
            #@cart.set_shipping(@cart.calc_shipping)
            #@order = Order.new


     
          end
        end
  
        #
        #  Shopping Cart 
        #
  
  
        def add_to_cart
          # user =  User.find_by_id(session[:user_id])

          @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id])

          #    @cart = Cart.get_cart(session[:cart])
          #    session[:cart] = @cart.id
          #  puts("cart id: #{@cart.id}")
       
    
          @product_detail=ProductDetail.where(:product_id=>params[:id], :color=>params[:color], :size=>params[:size]).first()
          # puts("Product in Add: #{@product_detail.product.inspect}")
          #  puts("Product Detail In Add: #{@product_detail.inspect}")
          # inventory_item_description = params.map {|k,vs| vs.map {|v| "#{k}:#{v}"}}.join(",")
          begin
            @current_item = @cart.add_product(@product_detail.product, @product_detail, params[:quantity])
            puts("Quantity Ordered: #{@current_item.quantity.inspect}")
            if @current_item.quantity >= @product_detail.units_in_stock  then
              puts("cart quantity:#{@current_item.quantity }, unit in stock: #{@product_detail.units_in_stock}")
              flash.now[:warning] ='Your request exceeds current inventory, your quantity has been reduced to what we have in stock.'
              # @current_item.quantity = @product_detail.units_in_stock.to_i
            end
    
            @flash_message = flash.now[:warning]
          rescue 
            @flash_message = "That product is currently unavailable."

          end
          respond_to do |format|
            format.json  { head :ok }
            format.html { render :text=>@flash_message }
          end
        end

        def hide_cart
          find_cart
          unless not @cart.visable then
            @cart.hide
            respond_to do |format|
              format.js if request.xhr?
              format.html {redirect_to :controller => 'store', :action => 'store_list'}
            end
          end
        end

  
        def show_cart
        #  user =  User.find_by_id(session[:user_id])

          # @cart = (session[:cart] ||= Cart.new)
          @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id])
          #   @cart = Cart.get_cart(session[:cart])
          #    puts("cart id: #{@cart.id}")

          unless @cart.visable then
            @cart.show
            respond_to do |format|
              format.js if request.xhr?
              format.html 
            end
          end
        end

        def toggle_cart
          find_cart
          if @cart.visable then
            hide_cart
          else
            show_cart
          end
        end
    
        def get_shopping_cart_item_info 
          find_cart
          @checkout_cart_item = @cart.items[params[:item_no].to_i]
          render :partial=>"/site/shopping_cart_item_info.html", :locals=>{:checkout_cart_item=>@checkout_cart_item}
        end
  
        def get_cart_summary_body 
          find_cart
          @checkout_cart = @cart
          render :partial=>"/site/cart_summary_body.html", :locals=>{:checkout_cart=>@checkout_cart}
        end
  
        def get_cart_contents 
          find_cart
          @checkout_cart = @cart
          render :partial => "checkout_cart_item" , :collection => @checkout_cart.items
        end
   
        def get_shopping_cart_info 
          find_cart
          render :partial=>"/site/shopping_cart_info.html"
        end
  
  
    
        def increment_cart_item
          find_cart
          @current_item_counter=params[:current_item]
          @current_item=@cart.items[@current_item_counter.to_i]
          @current_item.increment_quantity
          @cart.save

          if @current_item.quantity >= @current_item.product_detail.units_in_stock  then
            puts("cart quantity:#{@current_item.quantity }, unit in stock: #{@current_item.product_detail.units_in_stock}")
            flash.now[:warning] ='Your request exceeds current inventory, your quantity has been reduced to what we have in stock.'
            # @current_item.quantity = @product_detail.units_in_stock.to_i
          end
    
          @flash_message = flash.now[:warning]
      
          respond_to do |format|
            format.json  { head :ok }
            format.html { render :text=>@flash_message }
          end

        end

        def decrement_cart_item
          find_cart
          @current_item_counter=params[:current_item]
          @current_item=@cart.items[@current_item_counter.to_i]
          @current_item.decrement_quantity
          if @current_item.quantity == 0 then
            @cart.items.delete_at(@current_item_counter.to_i)
          end
    
          @cart.save
          respond_to do |format|
            format.json  { head :ok }
            format.html {render :nothing=>true}
          end
        end

        def delete_cart_item
          find_cart
          @current_item_counter=params[:current_item]
          @current_item=@cart.items.delete_at(@current_item_counter.to_i)
          @cart.save

          respond_to do |format|
            format.json  { head :ok }
            format.html {render :nothing=>true}
          end
        end
       
        def empty_cart_no_redirect
          find_cart
          @cart.delete
          session[:cart] = nil
          find_cart
        end
        
        def empty_cart
          find_cart
          @cart.delete
          session[:cart] = nil
          find_cart
    
          #    render(:nothing => true)

          #    redirect_to_index

          #        find_cart
          #    @cart=nil
          #    session[:cart] = nil
          respond_to do |format|
            format.js if request.xhr?
            format.html {redirect_to :controller => 'site', :action => 'index'}
          end

    
          def save_order
            $hostfull = request.protocol + request.host_with_port

   
            session[:mainnav_status] = false
  
            @order = Order.new(params[:order])
            @order.add_line_items_from_cart(@cart, $hostfull)
            @order.user = User.find_by_id(session[:user_id])
            @order.ip_address = request.remote_ip
            @order.email = @order.user.name
            @order.cart_type="CreditCard"
      
            if @order.save
              return_response=@order.purchase
              if return_response.success?
                flash[:notice] = "Thank you for your Order!!"
                session[:cart] = nil
                redirect_to( :action => :success, :controller=>"orders", :id=>@order.id)
                #     redirect_to( :action => :customer_detail, :controller=>"orders", :id=>@order.id)

              else
                flash[:notice] = "Transaction failed! <br> <br> <br>" + return_response.message
                render :action => 'checkoutcc'

              end

              #        session[:cart] = nil
              #    redirect_to_index("Thank you for your order")
            else
              render :action => 'checkoutcc'
            end

          end

        end

  
        def cart_update
          find_cart
    
          @cart.coupon_code= params[:cart][:coupon_code]
          @cart.save
    
          puts(@cart.inspect)
          render :text=>params[:cart][:coupon_code]
        end
  
        def load_product_style_slider
  
          render :partial=>"/site_includes/load_product_style_slider.html", :locals=>{:blah=>"test"}

  
        end
  
        def retailers
          @retailers = Retailer.all

          respond_to do |format|
            format.html # index.html.erb
            format.json 
          end
        end
  
        def product_index_feed
    
          @google_taxonomy = "Apparel & Accessories > Clothing > Swimwear"
          @full_url_path = request.protocol +  request.host_with_port
          @products = Product.where(:product_active=>true)
    
        end
  
        private 
  
  
        def find_cart
          #  @cart = (session[:cart] ||= Cart.new)
          #user =  User.find_by_id(session[:user_id])

          session[:create]=true
    
          @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id]) rescue  Rails.cache.write("cart"+session[:session_id],{}, :expires_in => 15.minutes)
          puts("@cart in find_cart: #{@cart}")
          
          if not params[:coupon_code].blank? then
            puts("Coupon Code Found")
            @cart.coupon_code = params[:coupon_code]
            @cart.save
          end
    
          #   @cart = Cart.get_cart(session[:cart])
          #    session[:cart] = @cart.id
        end

        def create_menu_lowest_child_list(menu_name, menu_id=nil,with_id=true)
          if menu_id.blank? then
            if menu_name.blank? then
              return []
            else
              @start_menu = Menu.find_by_name(menu_name)
              if @start_menu.blank? then
                return "no menu found"
              end
            end
          else
            @start_menu = Menu.find(menu_id)
          end
      
          @menus = Menu.find_menu(@start_menu.id)
      
          return_list = []
          @menus.each do |menu|
            if menu.menus.size == 0 then
              if with_id then
                return_list = return_list + [[menu.name, menu.id]]
              else
                return_list = return_list + [menu.name]
              end
            else
              return_list= return_list + create_menu_lowest_child_list("",menu.id,with_id)
            end
          end
          return return_list
        end
  
        
      end
    
    end
  
  


  end

end