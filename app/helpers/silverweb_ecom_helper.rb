module SilverwebEcomHelper

def display_page_body(page_name) 
    page = Page.where(:title=>page_name).first rescue ""
    
    return page.body.html_safe rescue "Page '#{page_name}' not found.   Please create it in pages."
  end
  
def json_clean(input)
    # return input.gsub('"', '\\"').gsub(/'/) {|s| "\\'"} 
    return input.gsub(/\n/," ").gsub(/\r/," ").gsub(/\\|"/) { |c| "\\#{c}" }.html_safe
    
  end
  
def build_product_list_templates 
     # paths = ActionController::Base.view_paths.map{|i| (i.to_path.include?("silverweb") ? i.to_path : "")}.delete_if(&:empty?)
    paths = ActionController::Base.view_paths
    template_types = [["B L A N K",""]]
    paths.each do |the_view_path|
      templates = Dir.glob(the_view_path.to_path+ "/site/show_products-*")
      
      templates.each do |template|
        template_name = template.split("/").last.split("-").drop(1).join("-").split(".").first
        template_types << [template_name + " Template",template_name] if not template_name.blank?
      end
    end
    
    return template_types
end
  
def find_cart
    # user =  User.find_by_id(session[:user_id])
    
#    p session.loaded?               
#    p session                       
#    session[:init] = true           
#    p session.loaded?               
#    p session      
    
    session[:session_id] = request.session_options[:id]

   #  puts("session[:user_id]: #{session[:user_id]}")
    session.delete 'init'
    @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id])
  #   puts("@cart: #{@cart.inspect}")

    #   @cart = Cart.get_cart(session[:cart])
    #   session[:cart] = @cart.id
  
  end
  
def express_checkout_link()
  return link_to(image_tag("https://www.paypal.com/en_US/i/btn/btn_xpressCheckout.gif"), express_purchase_orders_path, {:class=>"paypal-button"}) if Settings.enable_paypal_express == "true"
end
  
# not used

def ecomm_attributes
    return_val = ""
    return_val  << "<div class='hidden-item'>"
    return_val  << " <div id='logged-in'>#{not User.find_by_id(session[:user_id]).blank?}</div>"
    return_val  << ""
    return_val  << "</div>"
    
    return return_val.html_safe
    
  end
  
def page_data_attr_ecom(addtional_script)
        return ("<div id='data-reload' class='hidden-item' data-page-params='#{request.original_url}' data-page-update='call_document_ready(\"#{controller_name + "_" + action_name}\")' data-additional='#{controller_name + "_" + addtional_script.sub("-","_")}'></div>").html_safe
  end
  

def product_data_attr(template_name="")
        return ("<div id='data-reload' class='hidden-item' data-page-params='/site/product_detail?id=#{@product.id}' data-page-update='site_product_detail', data-additional='#{template_name}'></div>").html_safe
  end
end