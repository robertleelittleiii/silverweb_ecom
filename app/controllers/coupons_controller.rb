# frozen_string_literal: true

class CouponsController < ApplicationController
  # GET /coupons
  # GET /coupons.json
  def index
    @settings = Settings.all
    @coupons = Coupon.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @coupons }
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
      format.json { render json: @coupon }
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
        format.html { redirect_to @coupon, notice: 'Coupon was successfully created.' }
        format.json { render json: @coupon, status: :created, location: @coupon }
      else
        format.html { render action: 'new' }
        format.json { render json: @coupon.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /coupons/1
  # PUT /coupons/1.json
  def update
    preferences_update = false

    if params[:id].blank?
      eval('Settings.' + params['settings'].to_a.first[0] + '="' + params['settings'].to_a.first[1].html_safe + '"')
      preferences_update = true
    else

      @coupon = Coupon.find(params[:id])
      successfull = @coupon.update_attributes(coupon_params)
      if (Coupon.columns_hash[params[:coupon].keys[0].to_s].type == :decimal) || (Coupon.columns_hash[params[:coupon].keys[0].to_s].type == :integer) || (Coupon.columns_hash[params[:coupon].keys[0].to_s].type == :float)
        params[:coupon][params[:coupon].keys[0]] = params[:coupon][params[:coupon].keys[0]].delete('$').delete(',')
      end

    end

    respond_to do |format|
      if preferences_update
        format.html { render nothing: true }
        format.json { render json: { notice: 'Preferences were successfully updated.' } }

      else
        if successfull
          format.html { redirect_to @coupon, notice: 'Coupon was successfully updated.' }
          format.json { head :ok }
        else
          format.html { render action: 'edit' }
          format.json { render json: @coupon.errors, status: 'unprocessable_entry' }
        end
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

  def delete_ajax
    @coupon = Coupon.find(params[:id])
    @coupon.destroy
    render nothing: true
  end

  # CREATE_EMPTY_RECORD /coupons/1
  # CREATE_EMPTY_RECORD /coupons/1.json

  def create_empty_record
    @coupon = Coupon.new
    @coupon.coupon_code = 'New Coupon'
    @coupon.description = 'New Description here...'
    @coupon.min_amount = 0
    @coupon.save

    redirect_to(controller: :coupons, action: :edit, id: @coupon)
  end

  def coupon_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render layout: false
  end

  private

  def current_objects(params = {})
    current_page = (begin
                      params[:start].to_i / params[:length].to_i
                    rescue StandardError
                      0
                    end) + 1
    @current_objects = Coupon.page(current_page).per(params[:length])
                             .order("#{datatable_columns(params[:order]['0'][:column])} #{params[:order]['0'][:dir] || 'DESC'}")
                             .where(conditions)

    # @current_objects = Coupon.select("coupons.*").
    #   where(conditions).
    #   order("#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}")
  end

  def total_objects(_params = {})
    @total_objects = Coupon.where(conditions).count
  end

  def datatable_columns(column_id)
    case column_id.to_i
    when 0
      'coupons.coupon_code'
    when 1
      'coupons.description'
    when 2
      'coupons.start_date'
    when 3
      'coupons.end_date'
    else
      'coupons.value'
    end
  end

  def conditions
    conditions = []
    conditions << "(coupons.coupon_code LIKE '%#{params[:search][:value]}%' OR coupons.description LIKE '%#{params[:search][:value]}%')" if params[:search][:value]
    conditions.join(' AND ')
  end

  def coupon_params
    params[:coupon].permit('description', 'start_date', 'end_date', 'coupon_code', 'value', 'min_amount', 'coupon_type', 'created_at', 'updated_at', 'one_time_only', 'only_most_expensive_item', 'coupon_calc')
  end
end
