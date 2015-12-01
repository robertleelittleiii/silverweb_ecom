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
      
    user =  User.find_by_id(session[:user_id])

    @cart=Cart.get_cart("cart"+session[:session_id], user.id)
    
    #   @cart = Cart.get_cart(session[:cart])
    #   session[:cart] = @cart.id
  
  end
  
end