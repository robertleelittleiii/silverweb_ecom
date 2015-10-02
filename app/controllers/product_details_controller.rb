class ProductDetailsController < ApplicationController
  # GET /product_details
  # GET /product_details.json
  def index
    @product_details = ProductDetail.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @product_details} 
    end
  end

  # GET /product_details/1
  # GET /product_details/1.json
  def show
    @product_detail = ProductDetail.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @product_detail }
    end
  end

  # GET /product_details/new
  # GET /product_details/new.json
  def new
    @product_detail = ProductDetail.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @product_detail}
    end
  end

  # GET /product_details/1/edit
  def edit
    if params[:request_type]== "nothing" then
      render nothing: true
    else
      @product_detail = ProductDetail.find(params[:id])

    end
  end

  # POST /product_details
  # POST /product_details.json
  def create
    @product_detail = ProductDetail.new(params[:product_detail])

    respond_to do |format|
      if @product_detail.save
        format.html { redirect_to @product_detail, notice: "Product detail was successfully created." }
        format.json { render json: @product_detail, status: :created, location: @product_detail }
      else
        format.html { render action: "new" }
        format.json { render json: @product_detail.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /product_details/1
  # PUT /product_details/1.json
  def update
    @product_detail = ProductDetail.find(params[:id])

    respond_to do |format|
      if @product_detail.update_attributes(product_detail_params)
        format.html { redirect_to @product_detail, notice: "Product detail was successfully updated."}
        format.json { render :json=> {:notice => 'Product was successfully updated.'} }
      else
        format.html { render action: "edit" }
        format.json { render json: @product_detail.errors, status: "unprocessable_entry" }
      end
    end
  end

  # DELETE /product_details/1
  # DELETE /product_details/1.json
  def destroy
    @product_detail = ProductDetail.find(params[:id])
    @product_detail.destroy

    respond_to do |format|
      format.html { redirect_to product_details_url }
      format.json { head :ok }
    end
  end
  
  # CREATE_EMPTY_RECORD /product_details/1
  # CREATE_EMPTY_RECORD /product_details/1.json

  def duplicate_record
    @old_product_detail = ProductDetail.find(params[:old_id])
    
    @product_detail = ProductDetail.new
    @product_detail.sku_active = @old_product_detail.sku_active
    @product_detail.product_id = @old_product_detail.product_id
    @product_detail.units_in_stock = @old_product_detail.units_in_stock
    @product_detail.units_on_order = @old_product_detail.units_on_order
    @product_detail.color= @old_product_detail.color
    #@product_detail.inventory_key =("0000000000" + (ProductDetail.maximum(:inventory_key).to_i + 1).to_s).last(10) if Settings.inventory_key_increment == true
    @product_detail.inventory_key = (ProductDetail.all(select: "Max(inventory_key+0) as max_key").first.max_key.to_i + 1).to_s if Settings.inventory_key_increment == true
    @product_detail.size = @old_product_detail.size
    @product_detail.save

    
    respond_to do |format|
      format.html { head :ok }
      format.json { head :ok }
    end
  end
  
  def create_empty_record
    @product_detail = ProductDetail.new
    @product_detail.product_id = params[:product_id] rescue nil
    @product_detail.units_in_stock = 0
    @product_detail.units_on_order = 0 
    @product_detail.color = "N/C"
    @product_detail.size = "N/S"
    #    @product_detail.inventory_key =("0000000000" + (ProductDetail.maximum(:inventory_key).to_i + 1).to_s).last(10) if Settings.inventory_key_increment == true
    @product_detail.inventory_key = (ProductDetail.all(select: "Max(inventory_key+0) as max_key").first.max_key.to_i + 1).to_s if Settings.inventory_key_increment == true
    #puts("ProductDetail.maximum(:inventory_key).to_i: #{ProductDetail.maximum(:inventory_key).to_i}")
    
    
    @product_detail.save
    

    redirect_to(controller: :product_details, action: :edit, request_type: params[:request_type], id: @product_detail)
    #   redirect_to(:controller=>:product_details, :action=>:edit, :id=>@product_detail)
  end

  
  def delete_ajax
    @product_detail= ProductDetail.find(params[:id])
    @product_detail.destroy
    render nothing: true
  end
  
  def product_details_table
    @product_details = ProductDetail.where(product_id: params[:product_id]);
    
    @colors =  @product_details.select("distinct `color`").collect{|x| x.color }
    @sizes =  Settings.inventory_size_list.split(",").collect{|x| x } || "" rescue []
    @system_colors = SystemImages.all.collect{|x| x.title}

    
    
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render layout: false
  end
  
  
   private
 
  def current_objects(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1
    @current_objects = ProductDetail.page(current_page).per(params[:iDisplayLength]).order("#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}").where(product_id: [params[:product_id]]).where(conditions)

  #  @current_objects = ProductDetail.where(:product_id=>[params[:product_id]]).paginate :page => current_page, 
  #    :order => "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}", 
  #    :where => conditions,
  #    :per_page => params[:iDisplayLength]
    
    # @current_objects = ProductDetail.select("product_details.*").
    #   where(conditions).
    #   order("#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}")
  
  
  end
    

  def total_objects(params={})
    @total_objects = ProductDetail.count
  end

  def datatable_columns(column_id)
    case column_id.to_i
    when 0
      return "product_details.sku_active"
    when 1
      return "product_details.inventory_key"
    when 2
      return "product_details.size"
    when 3
      return "product_details.color"
    when 4
      return "product_details.units_in_stock"
    else
      return "product_details.units_on_order"
    end
  end

  def conditions
    conditions = []
    conditions << "(product_details.inventory_key LIKE '%#{params[:sSearch]}%' OR product_details.size LIKE '%#{params[:sSearch]}%' OR product_details.color LIKE '%#{params[:sSearch]}%'OR product_details.units_in_stock LIKE '%#{params[:sSearch]}%')" if(params[:sSearch])
    return conditions.join(" AND ")
  end
  
   def product_detail_params
    params[:product_detail].permit("product_id", "inventory_key", "size", "color", "units_in_stock", "units_on_order", "created_at", "updated_at", "sku_active")
  end

  
end
