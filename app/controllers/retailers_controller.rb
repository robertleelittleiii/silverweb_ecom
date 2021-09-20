# frozen_string_literal: true

class RetailersController < ApplicationController
  # GET /retailers
  # GET /retailers.json
  def index
    @retailers = Retailer.all

    respond_to do |format|
      format.html # index.html.erb
      format.json
    end
  end

  # GET /retailers/1
  # GET /retailers/1.json
  def show
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @retailer }
    end
  end

  # GET /retailers/new
  # GET /retailers/new.json
  def new
    @retailer = Retailer.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @retailer }
    end
  end

  # GET /retailers/1/edit
  def edit
    @retailer = Retailer.find(params[:id])
  end

  # POST /retailers
  # POST /retailers.json
  def create
    @retailer = Retailer.new(retailer_params)

    respond_to do |format|
      if @retailer.save
        format.html { redirect_to @retailer, notice: 'Retailer was successfully created.' }
        format.json { render json: @retailer, status: :created, location: @retailer }
      else
        format.html { render action: 'new' }
        format.json { render json: @retailer.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /retailers/1
  # PUT /retailers/1.json
  def update
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      if @retailer.update_attributes(retailer_params)
        format.html { redirect_to @retailer, notice: 'Retailer was successfully updated.' }
        format.json { head :ok }
      else
        format.html { render action: 'edit' }
        format.json { render json: @retailer.errors, status: 'unprocessable_entry' }
      end
    end
  end

  # DELETE /retailers/1
  # DELETE /retailers/1.json
  def destroy
    @retailer = Retailer.find(params[:id])
    @retailer.destroy

    respond_to do |format|
      format.html { redirect_to retailers_url }
      format.json { head :ok }
    end
  end

  # CREATE_EMPTY_RECORD /retailers/1
  # CREATE_EMPTY_RECORD /retailers/1.json

  def create_empty_record
    @retailer = Retailer.new
    @retailer.company_name = "New Company"
    @retailer.save

    redirect_to(controller: :retailers, action: :edit, id: @retailer)
  end

  def delete_ajax
    @retailer = Retailer.find(params[:id])
    @retailer.destroy
    head :ok
    
  end

  def retailer_table
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
                  
    @current_objects = Retailer.page(current_page).per(params[:length])
    .order("#{datatable_columns(params[:order]['0'][:column])} #{params[:order]['0'][:dir] || 'DESC'}")
    .where(conditions)

    # @current_objects = Retailer.select("retailers.*").
    #   where(conditions).
    #   order("#{datatable_columns(params[:order]["0"][:column])} #{params[:order]["0"][:dir] || "DESC"}")
  end

  def total_objects(_params = {})
    @total_objects = Retailer.where(conditions).count
  end

  def datatable_columns(column_id)
    case column_id.to_i
    when 0
      'retailers.company_name'
    when 1
      'retailers.company_street_1'
    when 2
      'retailers.company_street_2'
    when 3
      'retailers.company_city'
    when 4
      'retailers.company_state'
    when 5
      'retailers.company_zip'
    when 6
      'retailers.company_phone'
    when 7
      'retailers.company_website'
    when 8
      'retailers.company_hours_1'
    when 9
      'retailers.company_hours_2'
    else
      'retailers.company_hours_3'
    end
  end

  def conditions
    conditions = []
    conditions << "(retailers.company_name LIKE '%#{params[:search][:value]}%' OR retailers.company_street_1 LIKE '%#{params[:search][:value]}%' OR retailers.company_street_2 LIKE '%#{params[:search][:value]}%' OR retailers.company_city LIKE '%#{params[:search][:value]}%' OR retailers.company_state LIKE '%#{params[:search][:value]}%' OR retailers.company_zip LIKE '%#{params[:search][:value]}%' OR retailers.company_phone LIKE '%#{params[:search][:value]}%' OR retailers.company_website LIKE '%#{params[:search][:value]}%' OR retailers.company_hours_1 LIKE '%#{params[:search][:value]}%' OR retailers.company_hours_2 LIKE '%#{params[:search][:value]}%' OR retailers.company_hours_3 LIKE '%#{params[:search][:value]}%')" if params[:search][:value]
    conditions.join(' AND ')
  end
  
    
  private
  
   def retailer_params
    params[:retailer].permit(["id", "company_name", "company_street_1", "company_street_2", "company_city", "company_state", "company_zip", "company_phone", "company_website", "company_hours_1", "company_hours_2", "company_hours_3", "latitude", "longitude", "created_at", "updated_at"])
  end
  
   
end
