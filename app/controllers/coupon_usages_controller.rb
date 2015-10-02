class CouponUsagesController < ApplicationController
  # GET /coupon_usages
  # GET /coupon_usages.json
  def index
    @coupon_usages = CouponUsage.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @coupon_usages} 
    end
  end

  # GET /coupon_usages/1
  # GET /coupon_usages/1.json
  def show
    @coupon_usage = CouponUsage.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @coupon_usage }
    end
  end

  # GET /coupon_usages/new
  # GET /coupon_usages/new.json
  def new
    @coupon_usage = CouponUsage.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @coupon_usage}
    end
  end

  # GET /coupon_usages/1/edit
  def edit
    @coupon_usage = CouponUsage.find(params[:id])
  end

  # POST /coupon_usages
  # POST /coupon_usages.json
  def create
    @coupon_usage = CouponUsage.new(params[:coupon_usage])

    respond_to do |format|
      if @coupon_usage.save
        format.html { redirect_to @coupon_usage, notice: "Coupon usage was successfully created." }
        format.json { render json: @coupon_usage, status: :created, location: @coupon_usage }
      else
        format.html { render action: "new" }
        format.json { render json: @coupon_usage.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /coupon_usages/1
  # PUT /coupon_usages/1.json
  def update
    @coupon_usage = CouponUsage.find(params[:id])

    respond_to do |format|
      if @coupon_usage.update_attributes(params[:coupon_usage])
        format.html { redirect_to @coupon_usage, notice: "Coupon usage was successfully updated."}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @coupon_usage.errors, status: "unprocessable_entry" }
      end
    end
  end

  # DELETE /coupon_usages/1
  # DELETE /coupon_usages/1.json
  def destroy
    @coupon_usage = CouponUsage.find(params[:id])
    @coupon_usage.destroy

    respond_to do |format|
      format.html { redirect_to coupon_usages_url }
      format.json { head :ok }
    end
  end
  
   # CREATE_EMPTY_RECORD /coupon_usages/1
   # CREATE_EMPTY_RECORD /coupon_usages/1.json

  def create_empty_record
    @coupon_usage = CouponUsage.new
    @coupon_usage.save
    
    redirect_to(controller: :coupon_usages, action: :edit, id: @coupon_usage)
  end

  
end
