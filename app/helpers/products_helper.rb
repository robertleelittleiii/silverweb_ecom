# frozen_string_literal: true

module ProductsHelper
  def create_group_checks_live(_field_name, field_pointer, value_list, tag_list_name, html_options = {})
    return_value = ''.dup

    value_list.each do |item|
      return_value = return_value + "<div class='div-#{tag_list_name}'>" + editablecheckboxtag2(item, field_pointer, item, tag_list_name, html_options) + '</div>'
    end
    return_value.html_safe
  end

  def product_info(product)
    returnval = '<div id="attr-products" class="hidden-item">'.dup
    returnval << '<div id="product-id">' + (begin
                                              product.id.to_s
                                            rescue StandardError
                                              '-1'
                                            end) + '</div>'

    returnval += '</div>'
    returnval.html_safe
  end

  def main_image_preview(picture)
    thumb_picture = picture.file_type == '.pdf' ? image_tag(picture.image_url(:pdf_thumb).to_s) : image_tag(picture.image_url(:thumb).to_s)
    preview_picture = picture.file_type == '.pdf' ? picture.image_url(:pdf_preview).to_s : picture.image_url(:large).to_s

    begin
      return(link_to(thumb_picture, preview_picture, class: 'zoom-image').gsub(/\\|"/) { |c| "\\#{c}" }.html_safe)
    rescue StandardError
      ''
    end
  rescue StandardError
    ''
  end

  def product_edit_div(product)
    returnval = ''.dup
    if session[:user_id]
      user = User.find(session[:user_id])
      if user.roles.detect { |role| ((role.name == 'Admin') | (role.name == 'Site Owner')) }
        returnval = '<div id="edit-product" class="edit-product">'.dup
        returnval << "<div id='product-id' class='hidden-item'>#{product.id}</div>"
        returnval += image_tag('interface/edit.png', border: '0', class: 'imagebutton', title: 'Edit this Product')
        returnval += '</div>'

      end
    end
    returnval.html_safe
  end

  def get_share_code_product
    if !Settings.product_javascript_social_share.blank?
      (CGI.unescapeHTML(Settings.product_javascript_social_share) + CGI.unescapeHTML(Settings.product_button_block_social_share)).html_safe
      #+ Settings.blog_button_block_social_share.html_safe
    else
      ''
    end
  end
end
