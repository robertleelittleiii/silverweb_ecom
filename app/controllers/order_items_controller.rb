class OrderItemsController < ApplicationController
  # GET /order_items
  # GET /order_items.json
  def index
    @order_items = OrderItem.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @order_items} 
    end
  end

  # GET /order_items/1
  # GET /order_items/1.json
  def show
    @order_item = OrderItem.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @order_item }
    end
  end

  # GET /order_items/new
  # GET /order_items/new.json
  def new
    @order_item = OrderItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @order_item}
    end
  end

  # GET /order_items/1/edit
  def edit
    @order_item = OrderItem.find(params[:id])
  end

  # POST /order_items
  # POST /order_items.json
  def create
    @order_item = OrderItem.new(order_items_params)

    respond_to do |format|
      if @order_item.save
        format.html { redirect_to @order_item, notice: "Order item was successfully created." }
        format.json { render json: @order_item, status: :created, location: @order_item }
      else
        format.html { render action: "new" }
        format.json { render json: @order_item.errors, status: :unprocessable_entry }
      end
    end
  end

  # PUT /order_items/1
  # PUT /order_items/1.json
  def update
    @order_item = OrderItem.find(params[:id])

    respond_to do |format|
      if @order_item.update_attributes(order_items_params)
        format.html { redirect_to @order_item, notice: "Order item was successfully updated."}
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @order_item.errors, status: "unprocessable_entry" }
      end
    end
  end

  # DELETE /order_items/1
  # DELETE /order_items/1.json
  def destroy
    @order_item = OrderItem.find(params[:id])
    @order_item.destroy

    respond_to do |format|
      format.html { redirect_to order_items_url }
      format.json { head :ok }
    end
  end
  
   # CREATE_EMPTY_RECORD /order_items/1
   # CREATE_EMPTY_RECORD /order_items/1.json

  def create_empty_record
    @order_item = OrderItem.new
    @order_item.save
    
    redirect_to(controller: :order_items, action: :edit, id: @order_item)
  end

  def order_items_params
    params[:order_item].permit("order_id", "product_id", "product_detail_id", "price", "quantity", "discount", "size", "color", "description", "title", "shipped", "shipped_date", "created_at", "updated_at")
  end
  
end
