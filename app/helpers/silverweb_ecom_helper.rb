module SilverwebEcomHelper


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
    
    puts("session[:user_id]: #{session[:user_id]}")

    @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id])
    puts("@cart: #{@cart.inspect}")

    #   @cart = Cart.get_cart(session[:cart])
    #   session[:cart] = @cart.id
  
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
  
end