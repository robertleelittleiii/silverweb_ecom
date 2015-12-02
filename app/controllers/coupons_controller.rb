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
    @coupon.save
    
    redirect_to(controller: :coupons, action: :edit, id: @coupon)
  end

  def coupon_params
    params[:coupon].permit( "description", "start_date", "end_date", "coupon_code", "value", "min_amount", "coupon_type", "created_at", "updated_at", "one_time_only", "only_most_expensive_item", "coupon_calc")
  end
  
end
