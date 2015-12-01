module SilverwebCms
  module Controller
    extend ActiveSupport::Concern  
  module ClassMethods
     def ecom_findcart
        
          before_filter :find_cart, :except => :empty_cart
        
       include SilverwebEcom::ControllerExtensions::SiteControllerExtensions
      end
  end
  end
end