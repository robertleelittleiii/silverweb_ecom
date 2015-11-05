module SilverwebEcom
  class Railtie < Rails::Railtie
    #    initializer "silverweb_portfolio.action_controller" do
    #      ActiveSupport.on_load(:action_controller) do
    #        puts "Extending #{self} with silverweb_portfolio"
    #        # ActionController::Base gets a method that allows controllers to include the new behavior
    #        include SilverwebPortfolio::ControllerExtensions # ActiveSupport::Concern
    #        config.to_prepare do
    #      SiteController.send(:include, SilverwebPortfolio::ControllerExtensions::SiteControllerExtensions)
    #    end
    #      end
    #    end
    
    # The block you pass to this method will run for every request in
    # development mode, but only once in production.
    
 
    initializer "silverweb_ecom.update_picture_model" do      
    
      SilverwebCms::Config.add_nav_item({:name=>"Products", :controller=>'products', :action=>'index'})
        
     SilverwebCms::Config.add_menu_class(["Show Products","menu_show_products"])
     # SilverwebCms::Config.add_menu_class(["Show Products with Page","menu_show_products_with_page"])
      
     # SilverwebCms::Config.add_menu_actions(["Show Portfolio",20])
      
      Picture.class_eval do
        belongs_to :products, :polymorphic => true
      end
      
      # Add taggability on this menu
      Menu.class_eval do
           acts_as_taggable_on :category, :department
      end
     
      
      ImageUploader.class_eval do
        
        version :swatch do 
          process :cropper=>[30,30]
        end
  
        version :collection_list do
          process :resize_to_fill =>[90,140]
        end

        version :store_list do
          process :resize_to_fill => [77,125]
        end   

        version :store_list_mm do
          process :resize_to_fill => [115,180]
        end
        
        version :store_list_horizontal do
          process :resize_to_limit => [237, 171]
        end
        
        version :small_h do
          process :resize_to_fill =>[100,65]
        end       
  
        version :view do
          process :resize_to_fill => [320, 441]
          # process :outliner 
        end

        version :view_h do
          process :resize_to_fill => [691,472]
          #  process :outliner
        end
          
        version :primary do
          process  :resize_to_fill =>[250,410]
          #  process :resize_to_limit => [270, 410]
          #  process :cropper=>[250,410]
          #  process :outliner
        end
  
        version :slider do
          process :resize_to_fill => [300, 185]
          #  process :outliner
        end
        # 
        #        version :artifact_slider do
        #          process :resize_to_fill => [885, 600]
        #        end
        #  
        #        version :artifact_custom_slider do
        #          process :resize_to_limit => [600, 615]
        #        end
        #  
        #        version :artifact_before do
        #          process :resize_to_limit => [375, 255]
        #        end
        #  
        #        version :artifact_list do
        #          process :resize_to_fill => [180, 130]
        #        end
        #
        #
      end
      
    end
    
    #    initializer "silverweb_portfolio.update_menu_defs" do
    #      MenusController::MENU_TYPES << ["Portfolio",6]
    #      MenusController::ACTION_TYPES << ["Show Portfolio",20]
    #    end
    
        config.to_prepare do
          SiteController.send(:include, SilverwebEcom::ControllerExtensions::SiteControllerExtensions)
          MenusController.send(:include, SilverwebEcom::ControllerExtensions::MenusControllerExtensions)

         end
    

  end
end