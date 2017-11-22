Rails.application.routes.draw do
  
  resources :product_related_products
  resources :retailers do
    collection do
      get "create_empty_record"
      get "delete_ajax"
      post "retailer_table"
    end
  end

  get "secure_site/wholesale_page"

  resources :coupon_usages

  resources :coupons do 
    collection do
      get "create_empty_record"
      post "coupon_table"
      get "delete_ajax"
      delete "delete" 
    #  put "index"
      put "update"

    end
    
  end
  
  resources :cart do
    collection do
      post "update"
    end
  end

  resources :order_items do
    collection do
      get "create_empty_record"
    end
  end

  resources :orders do
    collection do
      get "show"
      get "create_empty_record"
      get "create_order"
      get "enter_order"
      post "enter_order"
      get "order_success"
      get "invoice_slip"
      get "user_orders"
      get "resend_invoice"
      post "order_table"
      post "user_order_table"
      get "express_purchase"
      get "product_list_report"
      get "customer_sales_report"
    end
  end
  
  resources :product_details do
    collection do
      get "create_empty_record"
      get "duplicate_record"
      post "product_details_table"
      get "delete_ajax"
      delete "delete" 
    end
  end

  resources :suppliers do
    collection do
      get "create_empty_record"
   
    end
  end

  resources :products do
    collection do
      get "create_empty_record"
      post "product_table"
      get "show_detail"
      post "render_category_div"
      get "render_image_section"
      get "delete_ajax"
      get "generate_inventory_report"
      post "update_checkbox_tag"
      post "add_image"
      get "edit_picture"
      get "edit_picture_swatch"
      post "update_image_order"
      get "product_preferences"
      post "add_image_system"
      get "reprocess_product_images"
      post "sort"
      post "update_related_order"
      get "product_search"
      post "update_related_list"
      post "render_related_section"
      get "render_swatch_picture"
      get "clean_product_details"
      get "activate_all_products"
      get "clear_product_inventory_and_make_all_inactive"
      get "hide_inactive_inventory"
      get "search_fields"
    end
  end
  
  resources :product_related_products do
    collection do
      delete "delete" 
    end
  end

  match "/site/show_products" => "site#show_products", via: :get
  match "/site/product_detail" => "site#product_detail", via: :get
  match "/site/add_to_cart" => "site#add_to_cart", via: :get
  match "/site/show_cart" => "site#show_cart", via: :get
  match "/site/empty_cart" => "site#empty_cart", via: :get
  match "/site/get_sizes_for_color" => "site#get_sizes_for_color", via: :get
  match "/site/get_shopping_cart_info" => "site#get_shopping_cart_info", via: :get
  match "/site/check_out" => "site#check_out", via: :get
  match "/site/cart_update" => "site#cart_update", via: [:get, :put]
  match "/site/increment_cart_item" => "site#increment_cart_item", via: :get
  match "/site/decrement_cart_item" => "site#decrement_cart_item", via: :get
  match "/site/delete_cart_item" => "site#delete_cart_item", via: :get
  match "/site/get_shopping_cart_item_info" => "site#get_shopping_cart_item_info", via: :get
  match "/site/get_cart_summary_body" => "site#get_cart_summary_body", via: [:get, :post, :put]
  match "/site/get_cart_contents" => "site#get_cart_contents", via: :get
  match "/site/show_products_with_page" => "site#show_products_with_page", via: :get
  match "/site/live_product_search" => "site#live_product_search", via: :get
  match "/site/load_product_style_slider" => "site#load_product_style_slider", via: :get
  match "/site/retailers" => "site#retailers", via: :get
  match "/site/product_index_feed" => "site#product_index_feed", via: :get

  match "/menus/update_checkbox_tag" => "menus#update_checkbox_tag", via: :post
  match "/menus/render_category_div" => "menus#render_category_div", via: :get
  
 
    
  # examples of site controller additions  
  #  match "/site/show_portfolios" => "site#show_portfolios", via: :get
  #  match "/site/artifact_detail" => "site#artifact_detail", via: :get

end
