atom_feed "xmlns:g" => "http://base.google.com/ns/1.0" do |feed|
  feed.title "SquirtiniBikini Products"
  # feed.updated @products.maximum(:updated_at)
  
  @products.each do |product|
    product.product_details.where(:sku_active=>true).each do |product_detail|
     product_url =  url_for(:only_path=>false, :controller=>"site", :action=>"product_detail", :id=>product.id)      
      feed.entry product_detail, :url=>product_url do |entry|
        #entry.id product.id
        puts(product_url)
        # => entry.tag!("g:id", product_detail.id)
        #entry.'g:id' product.id
        entry.title product.product_name
        entry.description product.product_description
        entry.tag!("g:google_product_category", h(@google_taxonomy))
       #  entry.tag!("g:g:product_type", answer)

        # =>   entry.link h(product_url)
        entry.tag!("g:image_link", @full_url_path + product.primary_image.image_url(:primary)) if not product.primary_image.blank?
        entry.tag!("g:condition", "New")
        entry.tag!("g:availability", "in stock")
        entry.tag!("g:price", product.msrp.to_s + " USD")
        entry.tag!("g:brand", "Squirtini Bikini")
        entry.tag!("g:item_group_id", product.supplier_product_id)
        entry.tag!("g:gender", "Female")
        entry.tag!("g:age_group", "Kids")
        entry.tag!("g:sale_price", product.price.to_s + " USD")
        #entry.tag!("g:sale_price_effective_date", "datefrom/dateto")

        product.pictures.where(:active_flag=>true).each_with_index do |picture, index|
         if index <= 5 then
           entry.tag!("g:additional_image_link", @full_url_path + picture.image_url(:large).to_s)
         end
        end
        entry.tag!("g:mpn", product_detail.inventory_key)
        entry.tag!("g:identifier_exists", (not product_detail.inventory_key.blank?))
        entry.tag!("g:color", product_detail.color)
        entry.tag!("g:size", product_detail.size)
        entry.tag!("g:size_type", "Regular")
        entry.tag!("g:size_system", "US")
        # entry.tag!("g:pattern","findpattern");
      end
    end
  end
end