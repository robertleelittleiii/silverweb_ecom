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
      format.json { render json: @retailer}
    end
  end

  # GET /retailers/1/edit
  def edit
    @retailer = Retailer.find(params[:id])
  end

  # POST /retailers
  # POST /retailers.json
  def create
    @retailer = Retailer.new(params[:retailer])

    respond_to do |format|
      if @retailer.save
        format.html { redirect_to @retailer, notice: "Retailer was successfully created." }
        format.json { render json: @retailer, status: :created, location: @retailer }
      else
        format.html { render action: "new" }
        format.json { render json: @retailer.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /retailers/1
  # PUT /retailers/1.json
  def update
    @retailer = Retailer.find(params[:id])

    respond_to do |format|
      if @retailer.update_attributes(params[:retailer])
        format.html { redirect_to @retailer, notice: "Retailer was successfully updated."}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @retailer.errors, status: "unprocessable_entry" }
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
    @retailer.save
    
    redirect_to(controller: :retailers, action: :edit, id: @retailer)
  end
  
  def delete_ajax
    @retailer = Retailer.find(params[:id])
    @retailer.destroy
    render nothing: true
  end
    
  
  def retailer_table
    @objects = current_objects(params)
    @total_objects = total_objects(params)
    render layout: false
  end
  
  private
 
  def current_objects(params={})
    current_page = (params[:iDisplayStart].to_i/params[:iDisplayLength].to_i rescue 0)+1
    @current_objects = Retailer.paginate page: current_page, 
      order: "#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}", 
      conditions: conditions,
      per_page: params[:iDisplayLength]
    
    # @current_objects = Retailer.select("retailers.*").
    #   where(conditions).
    #   order("#{datatable_columns(params[:iSortCol_0])} #{params[:sSortDir_0] || "DESC"}")
  
  
  end
    

  def total_objects(params={})
    @total_objects = Retailer.count
  end

  def datatable_columns(column_id)
    case column_id.to_i
    when 0
      return "retailers.company_name"
    when 1
      return "retailers.company_street_1"
    when 2
      return "retailers.company_street_2"
    when 3
      return "retailers.company_city"
    when 4
      return "retailers.company_state"
    when 5
      return "retailers.company_zip"
    when 6
      return "retailers.company_phone"
    when 7
      return "retailers.company_website"
    when 8
      return "retailers.company_hours_1"
    when 9
      return "retailers.company_hours_2"
    else
      return "retailers.company_hours_3"
    end
  end

  def conditions
    conditions = []
    conditions << "(retailers.company_name LIKE '%#{
          params[:sSearch]}%' OR retailers.company_street_1 LIKE '%#{
          params[:sSearch]}%' OR retailers.company_street_2 LIKE '%#{
          params[:sSearch]}%' OR retailers.company_city LIKE '%#{
          params[:sSearch]}%' OR retailers.company_state LIKE '%#{
          params[:sSearch]}%' OR retailers.company_zip LIKE '%#{
          params[:sSearch]}%' OR retailers.company_phone LIKE '%#{
          params[:sSearch]}%' OR retailers.company_website LIKE '%#{
          params[:sSearch]}%' OR retailers.company_hours_1 LIKE '%#{
          params[:sSearch]}%' OR retailers.company_hours_2 LIKE '%#{
          params[:sSearch]}%' OR retailers.company_hours_3 LIKE '%#{
          params[:sSearch]}%')" if(params[:sSearch])
    return conditions.join(" AND ")
  end
end
