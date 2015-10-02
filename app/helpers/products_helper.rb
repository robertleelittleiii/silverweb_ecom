module ProductsHelper

  def create_group_checks_live(field_name, field_pointer, value_list, tag_list_name, html_options={})
    return_value = ""
    
    value_list.each do |item|
      return_value =  return_value + "<div class='div-#{tag_list_name}'>"+ editablecheckboxtag2(item, field_pointer,item,tag_list_name,html_options) +"</div>" 
    end
    return return_value.html_safe
  end

  def product_info(product)
    returnval = "<div id=\"attr-products\" class=\"hidden-item\">"
    returnval << "<div id=\"product-id\">"+(product.id.to_s rescue "-1")+"</div>"
    
    returnval=returnval + "</div>"
    return returnval.html_safe
 
  end

  def main_image_preview(picture)
    begin
    thumb_picture = picture.file_type==".pdf" ? (image_tag(picture.image_url(:pdf_thumb).to_s)) : (image_tag(picture.image_url(:thumb).to_s))
    preview_picture = picture.file_type==".pdf" ? picture.image_url(:pdf_preview).to_s : picture.image_url(:large).to_s

    return(link_to(thumb_picture,preview_picture,{:class=>"zoom-image"} ).gsub(/\\|"/) { |c| "\\#{c}" }.html_safe) rescue "" 
    rescue 
      return ""
    end
  end
  
end
