module EcomMenuHelper
  

def menu_show_products(menuItem, html_options, span_options, class_options=nil, options=nil)
    return_link = ""
    
    puts("options-> #{options}")
    
    class_options==nil ? class_options={} : ""
    
    puts("menuItem.name:#{menuItem.name}")
    
    if menuItem.menu_active then
      menuText="<span "+ span_options +">"+menuItem.name + "</span>"

      if not options.blank? then
        if not options[:menu_name_sub_container].blank? then
          menu_sub_container_start = "<#{options[:menu_name_sub_container]}>"
          menu_sub_container_end= "</#{options[:menu_name_sub_container]}>"
        else
          menu_sub_container_start =  menu_sub_container_end= ""
        end
      
        if not options[:menu_name_container].blank? then
          menuText="<#{options[:menu_name_container]}" + span_options +">"+ menu_sub_container_start + menuItem.name + menu_sub_container_end + "</{options[:menu_name_container]}>"
        else
          menuText="<span "+ span_options +">"+ menu_sub_container_start + menuItem.name + menu_sub_container_end + "</span>"

        end
      end
      
      #  menuText="<span "+ span_options +">"+menuItem.name + "</span>"
      #top_menu = Menu.find(session[:parent_menu_id]) rescue {}
      if menuItem.menu.parent_id == 0 then
        top_menu = menuItem
      else
        top_menu = menuItem.menu
      end
        
      if(menuItem.has_image and not menuItem.pictures.empty?) then
        image_to_link_to = menuItem.pictures[0].image_url.to_s rescue "interface/missing_image_very_small.png"
        item_link_to = image_tag(image_to_link_to, :border=>"0", :alt=>menuItem.name.html_safe)
      else
        item_link_to = menuText.html_safe
      end
       
     department_id = menuItem.department_list.first 
     category_id = menuItem.category_list.first
     template_name = !menuItem.rawhtml.to_s.blank? ? "show_products-"+menuItem.rawhtml.to_s : ""
     page_name  =  !menuItem.page.blank? ?  menuItem.page.title.to_s : ""
     
      class_options.merge!({:controller=>:site, :action=>:show_products, :department_id=>department_id, :category_id=>category_id, :template=>template_name, :page_name=>page_name})

#      case menuItem.rawhtml
#          
#      
#      when "","0"
#        class_options.merge!({:controller=>:site, :action=>:article_list,:department_id=>top_menu.name, :category_id=>menuItem.name,})
#      when "1"
#        class_options.merge!({:controller=>:site, :action=>:article_list_block,:department_id=>top_menu.name, :category_id=>menuItem.name,})
#      when "2"
#        class_options.merge!({:controller=>:site, :action=>:article_list_wide,:department_id=>top_menu.name, :category_id=>menuItem.name,})
#      when "3"
#        class_options.merge!({:controller=>:site, :action=>:article_list,:layout_format=>:long, :department_id=>top_menu.name, :category_id=>menuItem.name,})
#      end 
     
    #  return_link =  link_to(item_link_to, class_options, html_options)

   #   class_options.merge!({:controller=>:site, :action=>:article_list, :department_id=>top_menu.name, :category_id=>top_menu.name, :category_children=>false, :get_first_sub=>true})
      return_link =  link_to(item_link_to,class_options , html_options)
       
      return return_link.html_safe rescue "<none>"
    
    else
      return ""
    end
  end
  
  end
