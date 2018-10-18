# frozen_string_literal: true

class ProductsController < ApplicationController
  #  uses_tiny_mce( options: AppConfig.full_mce_options.merge({width: "897px"}),  only: [:new, :edit],
  #    raw_options: "template_templates : [ {
  #                                                        title : 'Editor Details',
  #                                                        src : 'editor_details.htm',
  #                                                        description : 'Adds Editors Name and Staff ID'
  #                                                    } ]#"
  #
  #
  #  )

  # GET /products
  # GET /products.json
  def index
    session[:mainnav_status] = true

    @products = Product.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @products }
    end
  end

  # GET /products/1
  # GET /products/1.json
  def show
    @product = Product.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/new
  # GET /products/new.json
  def new
    @product = Product.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product }
    end
  end

  # GET /products/1/edit
  def edit
    session[:mainnav_status] = true

    @product = Product.find(params[:id])
    @colors =  @product.product_details.select('distinct `color`').collect(&:color)
    @image_locations = ['Slider', 'Primary', 'Product List', '-']
    @product_layouts = [['Normal', ''], %w[Horizontal horizontal]]

    @sizes = begin
      Settings.inventory_size_list.split(',').collect { |x| x } || ''.dup
    rescue StandardError
      []
    end
    @system_colors = SystemImages.swatches.collect(&:title)
  end

  # POST /products
  # POST /products.json
  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render json: @product, status: :created, location: @product }
      else
        format.html { render action: 'new' }
        format.json { render json: @product.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /products/1
  # PUT /products/1.json
  def update
    preferences_update = false

    if (params[:id] == 'product_preferences') || (params[:id] == 'settings')
      if params['settings'].to_a.first[0] == 'category_group'
        category_list = Settings.category_group.to_s
        category = params['settings'].to_a.first[1]
        if category_list.include?(category)
          new_cat_list = category_list.to_s.split(',').reject { |elem| elem == category }.join(',')
        else
          new_cat_list = (category_list.to_s.split(',') << category).join(',')
        end
        Settings.category_group = new_cat_list
      else
        eval('Settings.' + params['settings'].to_a.first[0] + '="' + params['settings'].to_a.first[1].html_safe + '"')
      end

      preferences_update = true
    else

      @product = Product.find(params[:id])
      successfull = @product.update_attributes(product_params)
    end

    respond_to do |format|
      if preferences_update
        format.html { render nothing: true }
        format.json { render json: { notice: 'Preferences were successfully updated.' } }

      else
        if successfull
          format.html { redirect_to action: 'edit', notice: 'Product was successfully updated.' }
          format.json { render json: { notice: 'Product was successfully updated.' } }
        else
          format.html { render action: 'edit' }
          format.json { render json: @product.errors, status: 'unprocessable_entry' }
        end
      end
    end
  end

  # DELETE /products/1
  # DELETE /products/1.json
  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      format.html { redirect_to products_url }
      format.json { head :ok }
    end
  end

  # CREATE_EMPTY_RECORD /products/1
  # CREATE_EMPTY_RECORD /products/1.json

  def create_empty_record
    @product = Product.new
    @product.product_name = 'New Product'
    @product.product_description = 'Edit Me.'
    @product.unit_price = 0
    @product.msrp = 0
    respond_to do |format|
      if @product.save then
        format.html { redirect_to action: 'edit', id: @product.id }
        format.json { render json: { notice: 'Product was successfully created.' } }
      else
        format.html { render action: 'edit' }
        format.json { render json: @product.errors, status: 'unprocessable_entry' }
      end
    end
  end

  def show_detail
    @product = Product.find(params[:id])
    @sizes = begin
      Settings.inventory_size_list.split(',').collect { |x| x } || []
    rescue StandardError
      []
    end
    @system_colors = SystemImages.swatches.collect(&:title)

    render partial: 'detail_list'
  end

  def product_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render layout: false
  end

  def add_image
    @product = Product.find(params[:id])
    @colors =  @product.product_details.select('distinct `color`').collect(&:color)
    @image_locations = ['Slider', 'Primary', 'Product List', '-']

    format = params[:format]
    image = params[:image]

    unless image.blank?
      @picture = Picture.new(image: image)
      @picture.position = 999
      @picture.active_flag = true
      image_saved = @picture.save
      @product.pictures << @picture
    end

    puts("@picture -----____----#{@picture.inspect}")
    puts("image_saved -----____----#{image_saved}")

    respond_to do |format|
      if image_saved
    #    format.js   { render action: '../pictures/create.js' }
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render json: @picture, status: :created, location: @picture }
      else
        format.html { render action: 'new' }
        format.json { render json: @picture.errors, status: :unprocessable_entry }
      end
    end
  end

  def add_image_system
    format = params[:format]

    @picture = SystemImages.new(params[:image_name], params[:image])
    @picture.resource_type = 'Swatch'

    (image_saved = !@picture.blank?) && @picture.save

    puts("@picture -----____----#{@picture.inspect}")
    puts("image_saved -----____----#{image_saved}")

    respond_to do |format|
      if image_saved
        format.js   { render action: '../pictures/create.js' }
        format.html { redirect_to @picture, notice: 'Picture was successfully created.' }
        format.json { render json: @picture, status: :created, location: @picture }
      else
        format.html { render action: 'new' }
        format.json { render json: @picture.errors, status: :unprocessable_entry }
      end
    end
  end

  def delete_image
    @product = Product.find(params[:incoming_id])
    @image = Picture.find(params[:id])
    @image.destroy

    respond_to do |format|
      format.js if request.xhr?
      format.html { redirect_to action: 'show', id: params[:menu_id] }
    end
  end

  def destroy_image
    @image = Picture.find(params[:id])
    @image.destroy
    redirect_to action: 'show', id: params[:menu_id]
  end

  def update_image_order
    params[:picture].each_with_index do |id, position|
      #   Image.update(id, :position => position)
      Picture.reorder(id, position)
    end
head :ok
  end

  def update_related_order
    params[:related].each_with_index do |id, position|
      #     related_product = ProductRelatedProduct.find(id)
      #     related_product.position = position
      #     related_product.save
      #   Image.update(id, :position => position)
      ProductRelatedProduct.reorder(id, position)
    end
head :ok

  end

  def edit_picture
    @picture = Picture.find(params[:picture_id])
    @image_locations = ['Slider', 'Primary', 'Product List', '-']
    @product = Product.find(@picture.resource_id)
    @colors =  @product.product_details.select('distinct `color`').collect(&:color)
    @image_locations += @colors

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @picture }
    end
  end

  def edit_picture_swatch
    @picture = Picture.find(params[:picture_id])
    @image_locations = ['Slider', 'Primary', 'Product List', '-']

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @picture }
    end
  end

  def update_checkbox_tag
    @product = Product.find(params[:id])
    @tag_name = params[:tag_name] || 'tag_list'
    # truely toggle the value

    if @product.send(@tag_name).include?(params[:field])
      @product.send(@tag_name).remove(params[:field])
    else
      @product.send(@tag_name).add(params[:field])
    end

    #    if params[:current_status]== "false" then
    #      @product.send(@tag_name).remove(params[:field])
    #    else
    #      @product.send(@tag_name).add(params[:field])
    #    end
    @product.save

    head :ok

    #   respond_to do |format|
    #       format.js if request.xhr?
    #       format.html {redirect_to :action => 'show', :id=>params[:id]}
    #  end
  end

  def render_category_div
    @product = Product.find(params[:id])
    render(partial: 'category_div')
  end

  def render_swatch_picture
    class_name = params[:class_name]

    @picture = Picture.where(id: params[:id]).first
    if class_name.blank?
      render partial: '/products/swatch_view.html'
    else
      render partial: class_name.downcase + 's' + '/swatch_view.html'
    end
  end

  def render_image_section
    @product = Product.find(params[:id])
    @colors = @product.product_details.select('distinct `color`').collect(&:color)
    @image_locations = ['Slider', 'Primary', 'Product List', '-']

    render(partial: 'image_section')
  end

  def render_related_section
    @product = Product.find(params[:id])

    render(partial: 'related_section')
  end

  def delete_ajax
    @product = Product.find(params[:id])
    @product.destroy
head :ok

  end

  def sort
    @products_per_page = Settings.products_per_page.to_i || 8
    @current_page = params[:page].to_i

    params['product'].each_with_index do |product_id, counter|
      product = Product.find(product_id)
      new_position = counter + ((@current_page - 1) * @products_per_page) + 1
      old_position = product.position
      #    puts("Product ID->#{product_id}: Old_position: #{product.position}, New Position: #{counter + ((@current_page - 1) * @products_per_page) + 1} ")
      if new_position != old_position
        product.position = new_position
        product.save
      end
    end
head :ok

  end

  def sort2
    @products_per_page = Settings.products_per_page.to_i || 8
    @products = Product.order('product_ranking DESC').order('position ASC').order('created_at DESC')
    @current_page = params[:page].to_i

    @products.each_with_index do |product, counter|
      puts("Counter-> #{counter}")
      puts("@current_page-> #{@current_page}")

      # offset_value = ((counter / @products_per_page) * @products_per_page) + 1
      offset_value = ((@current_page - 1) * @products_per_page) + 1
      puts("offset_value-> #{offset_value}")
      puts("params['product'].index(product.id.to_s) + offset_value-> #{begin
        params['product'].index(product.id.to_s) + offset_value
        rescue StandardError
        'error'
        end}")
      puts("params['product'].index(product.id.to_s) -> #{params['product'].index(product.id.to_s)}")
      product.position = begin
        params['product'].index(product.id.to_s) + offset_value
      rescue StandardError
        product.position
      end
      product.save
    end
head :ok

  end

  def generate_inventory_report
    @products = Product.eager_load(:product_details).where('product_details.units_in_stock > 0').where(product_active: true).order(:supplier_product_id)

    respond_to do |format|
      format.html { render 'reports/generate_inventory_report.html', layout: 'print' }
      format.csv do
        headers['Content-Disposition'] = 'attachment; filename="product-list.csv"'
        headers['Content-Type'] ||= 'text/csv'
        render '/reports/generate_inventory_report.csv'
      end
    end
  end

  def product_preferences
    @settings = Settings.all
    @all_pictures = SystemImages.swatches.order(id: :desc)

    @template_types = [] # TEMPLATE_TYPES
    @categories = Product.category_counts.pluck(:name)

    paths = ActionController::Base.view_paths

    template_types = [['B L A N K', '']]
    paths.each do |the_view_path|
      templates = Dir.glob(the_view_path.to_path + '/site/product_detail-*')

      templates.each do |template|
        template_name = template.split('/').last.split('-').drop(1).join('-').split('.').first
        template_types << [template_name + ' Template', template_name] unless template_name.blank?
      end
    end

    search_template_types = [['B L A N K', '']]
    paths.each do |the_view_path|
      templates = Dir.glob(the_view_path.to_path + '/site/show_products_search-*')

      templates.each do |template|
        template_name = template.split('/').last.split('-').drop(1).join('-').split('.').first
        search_template_types << [template_name + ' Search Template', template_name] unless template_name.blank?
      end
    end

    preference_panes = []

    paths.each do |the_view_path|
      pref_panes_erbs = Dir.glob(the_view_path.to_path + '/products/_custom_prefs0*')
      pref_panes_erbs.each do |pref_panes_erb|
        puts(pref_panes_erb)
        pref_pane_name = pref_panes_erb.split('/').last.split('0').drop(1).join('-').split('.').first
        preference_panes << pref_pane_name unless pref_pane_name.blank?
      end
    end

    @template_types = template_types
    @preference_panes = preference_panes
    @search_template_types = search_template_types

    @template_list_types = []
    params[:action_name] = 'add_image_system'
    paths = ActionController::Base.view_paths
    template_list_types = [['B L A N K', '']]
    paths.each do |the_view_path|
      templates = Dir.glob(the_view_path.to_path + '/site/show_products-*')

      templates.each do |template|
        template_name = template.split('/').last.split('-').drop(1).join('-').split('.').first
        template_list_types << [template_name + ' Template', template_name] unless template_name.blank?
      end
    end

    @template_list_types = template_list_types

    params[:action_name] = 'add_image_system'
    #    if request.put?
    #     head :ok
    #    else
    #    end
  end

  def product_search
    if params[:term].blank?
      @products = Product.all
    else
      @products = Product.where("`product_name` like '%#{params[:term]}%' or `product_description` like '%#{params[:term]}%'or `supplier_product_id` like '%#{params[:term]}%'")
    end

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  def update_related_list
    @product = Product.find(params[:id])
    check_for_duplicate = ProductRelatedProduct.where(product_id: params[:id]).where(related_product_id: params[:related_id])
    if check_for_duplicate.empty?
      @related_product = ProductRelatedProduct.new
      @related_product.related_product_id = params[:related_id]
      @related_product.position = 999
      @related_product.save
      @product.related << @related_product
      @product.save
      render json: { success: true, alert: "Related Product '" + @related_product.related_product.product_name.to_s + "' added to this product." }
    else
      render json: { success: false, alert: 'Can not add related product.' }

    end
  end

  def reprocess_product_images
    @products = Product.all

    @products.each do |product|
      product.pictures.each do |picture|
        picture.image.recreate_versions!
      end
    end
    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to action: 'site_settings', id: params[:product_id] }
    end
  end

  def clean_product_details
    puts('**** Begin Clean of DB: Lost Children')
    bulk_clean_product_detail_sql = ["
      Delete
      FROM product_details
      WHERE NOT EXISTS (
            SELECT 1 FROM products
            WHERE products.id = product_details.product_id
           );
      "]

    bulk_clean_product_detail_2_sql = ["Delete FROM product_details WHERE inventory_key LIKE '%%.0'"]

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clean_product_detail_2_sql)
      result = ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      puts "something went wrong with the bulk clean sql query 2 #{result.inspect}: #{sql.inspect}"
    end

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clean_product_detail_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      'something went wrong with the bulk insert sql query'
    end

    puts('**** Begin Clean of DB: BAD UPC Children')

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to action: 'site_settings', id: params[:product_id] }
    end
    puts('**** END Clean of DB')
  end

  def activate_all_products
    bulk_activate_products_sql = ["
         Update
           products p
         Join
           product_details pd on p.id = pd.product_id
         SET
           p.product_active = 1
         where
           pd.units_in_stock > 0
      "]

    bulk_activate_details_sql = ["
        Update
           product_details pd
         SET
           pd.sku_active = 1
         where
           pd.units_in_stock > 0;
      "]

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_activate_products_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      'something went wrong with the bulk insert sql query'
    end

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_activate_details_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      'something went wrong with the bulk insert sql query'
    end

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to action: 'site_settings', id: params[:product_id] }
    end
  end

  def clear_product_inventory_and_make_all_inactive
    puts('**** Begin Clean of DB: clear active products')
    bulk_clear_active_product_flag_sql = ["
      Update
         products p
      SET
         p.product_active = 0
      where 1=1
      "]

    bulk_clear_active_product_detail_flag_sql = ["
      Update
         product_details pd
      SET
         pd.sku_active = 0,
         pd.units_in_stock = 0
      where 1=1
      "]

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clear_active_product_flag_sql)
      result = ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      puts "something went wrong with the bulk clear active products #{result.inspect}: #{sql.inspect}"
    end

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clear_active_product_detail_flag_sql)
      ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      'something went wrong with the bulk clear active product details'
    end

    puts('**** Begin Clean of DB: BAD UPC Children')

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to action: 'site_settings', id: params[:product_id] }
    end
    puts('**** END Clean of DB')
  end

  def hide_inactive_inventory
    puts('**** Begin Clean of DB: clear active products')

    bulk_clear_active_product_flag_sql = ["
      Update
         products p
      SET
         p.product_active = 0
      where 1=1
      "]

    hide_outofstock_items = ["
      UPDATE `products` pu SET pu.product_active = 1
      WHERE pu.id IN (
        SELECT
          p.id
        FROM
         (select * from `products`) p
        JOIN
          `product_details` pd
        ON
          pd.product_id = p.id
        WHERE
          pd.units_in_stock > 0
        GROUP BY
          p.id
        )
      "]

    clear_inactive_inventory = ["
      Update
         product_details pd
      SET
         pd.sku_active = 0
      where
         pd.units_in_stock <= 0
      "]

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, bulk_clear_active_product_flag_sql)
      result = ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      puts "something went wrong with the bulk clear all active product flags #{result.inspect}: #{sql.inspect}"
    end

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, clear_inactive_inventory)
      result = ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      puts "something went wrong with the bulk clear inactive inventory #{result.inspect}: #{sql.inspect}"
    end

    begin
      sql = ActiveRecord::Base.send(:sanitize_sql_array, hide_outofstock_items)
      ActiveRecord::Base.connection.execute(sql)
    rescue StandardError
      'something went wrong with the bulk hide out of stock items.'
    end

    puts('**** Begin Clean of DB: BAD UPC Children')

    respond_to do |format|
      format.json { head :ok }
      format.html { redirect_to action: 'site_settings', id: params[:product_id] }
    end
    puts('**** END Clean of DB')
  end

  def search_fields
    @return_fields =
      [{ label: 'description', value: 'product_description' },
      { label: 'name', value: 'product_name' },
      { label: 'style', value: 'supplier_product_id' }]

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @return_fields }
    end
  end

  private

  def current_objects(params = {})
    current_page = (begin
        params[:start].to_i / params[:length].to_i
      rescue StandardError
        0
      end) + 1
    @current_objects = Product.page(current_page).per(params[:length])
    .order("#{datatable_columns(params[:order]['0'][:column])} #{params[:order]['0'][:dir] || 'DESC'}")
    .where(conditions)

    # @current_objects = Product.select("products.*").
    #   where(conditions).
    #   order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir] || "DESC"}")
  end

  def total_objects(_params = {})
    @total_objects = Product.where(conditions).count
  end

  def datatable_columns(column_id)
    case column_id.to_i
    when 0
      'products.supplier_product_id'
    when 1
      'products.product_name'
    else
      'products.product_description'
    end
  end

  def conditions
    conditions = []

    params[:search][:value].split(',').each do |raw_search_term|
      search_term = raw_search_term.strip
      search_term_field = search_term.split(':')
      if search_term_field.length > 1
        search_joins = search_term_field[0].split('.')
        if search_joins.length > 1
          conditions << if search_term_field[1] == '!'
            "#{search_term_field[0]} is null"
          else
            "#{search_term_field[0]} like '#{search_term_field[1]}%'"
          end
        elsif Product.attribute_names.include?(search_term_field[0])
          conditions << if search_term_field[1] == '!'
            "#{search_term_field[0]} is null"
          else
            "products.#{search_term_field[0]} like '#{search_term_field[1]}%'"
          end
        end
      else
        if search_term
          conditions << "(products.product_name LIKE '%#{search_term}%' OR
                products.product_description LIKE '%#{search_term}%' OR
                products.supplier_product_id LIKE '%#{search_term}%' OR
                products.sheet_name LIKE '%#{search_term}%')"
        end
      end
    end
    conditions.join(' AND ')
  end

  def product_params
    params[:product].permit('product_id', 'sku', 'supplier_product_id', 'product_name', 'product_description', 'supplier_id', 'department_id', 'category_id', 'quantity_per_unit', 'unit_size', 'unit_price', 'msrp', 'product_detail_id', 'discount', 'unit_weight', 'reorder_level', 'product_active', 'discount_available', 'product_ranking', 'created_at', 'updated_at', 'supplier_name', 'is_taxable', 'position', 'size_label', 'sheet_name', 'custom_layout', 'search_terms', 'no_coupon')
  end
end
