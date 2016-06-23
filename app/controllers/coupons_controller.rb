class CouponsController < ApplicationController
  # GET /coupons
  # GET /coupons.json
  def index
    @coupons = Coupon.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @coupons} 
    end
  end

  # GET /coupons/1
  # GET /coupons/1.json
  def show
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @coupon }
    end
  end

  # GET /coupons/new
  # GET /coupons/new.json
  def new
    @coupon = Coupon.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @coupon}
    end
  end

  # GET /coupons/1/edit
  def edit
    @coupon = Coupon.find(params[:id])
  end

  # POST /coupons
  # POST /coupons.json
  def create
    @coupon = Coupon.new(coupon_params)

    respond_to do |format|
      if @coupon.save
        format.html { redirect_to @coupon, notice: "Coupon was successfully created." }
        format.json { render json: @coupon, status: :created, location: @coupon }
      else
        format.html { render action: "new" }
        format.json { render json: @coupon.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /coupons/1
  # PUT /coupons/1.json
  def update
    @coupon = Coupon.find(params[:id])

    respond_to do |format|
      if @coupon.update_attributes(coupon_params)
        format.html { redirect_to @coupon, notice: "Coupon was successfully updated."}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @coupon.errors, status: "unprocessable_entry" }
      end
    end
  end

  # DELETE /coupons/1
  # DELETE /coupons/1.json
  def destroy
    @coupon = Coupon.find(params[:id])
    @coupon.destroy

    respond_to do |format|
      format.html { redirect_to coupons_url }
      format.json { head :ok }
    end
  end
  
   # CREATE_EMPTY_RECORD /coupons/1
   # CREATE_EMPTY_RECORD /coupons/1.json

  def create_empty_record
    @coupon = Coupon.new
    @coupon.coupon_code = "New Coupon"
    @coupon.description = "New Description here..."
    @coupon.save
    
    redirect_to(controller: :coupons, action: :edit, id: @coupon)
  end

  def coupon_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render layout: false
  end
  
    
  private
 
  def current_objects(params={})
    current_page = (params[:start].to_i/params[:length].to_i rescue 0)+1
    @current_objects = Coupon.page(current_page).per(params[:length]). 
      order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir]  || "DESC"}").
      where(conditions)
    
    # @current_objects = Coupon.select("coupons.*").
    #   where(conditions).
    #   order("#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}")
  
  
  end
    

  def total_objects(params={})
    @total_objects = Coupon.where(conditions).count
  end

  def datatable_columns(column_id)
    case column_id.to_i
    when 0
      return "coupons.coupon_code"
    when 1
      return "coupons.description"
    when 2
      return "coupons.start_date"
    when 3
      return "coupons.end_date"
    else
      return "coupons.value"
    end
  end

  def conditions
    conditions = []
    conditions << "(coupons.coupon_code LIKE '%#{params[:search][:value]}%' OR coupons.description LIKE '%#{params[:search][:value]}%')" if(params[:search][:value])
    return conditions.join(" AND ")
  end
  
  def coupon_params
    params[:coupon].permit( "description", "start_date", "end_date", "coupon_code", "value", "min_amount", "coupon_type", "created_at", "updated_at", "one_time_only", "only_most_expensive_item", "coupon_calc")
  end
  
  
end
