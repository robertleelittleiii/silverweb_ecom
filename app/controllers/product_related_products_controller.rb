class ProductRelatedProductsController < ApplicationController
  before_action :set_product_related_product, only: [:show, :edit, :update, :destroy]

  # GET /product_related_products
  def index
    @product_related_products = ProductRelatedProduct.all
  end

  # GET /product_related_products/1
  def show
  end

  # GET /product_related_products/new
  def new
    @product_related_product = ProductRelatedProduct.new
  end

  # GET /product_related_products/1/edit
  def edit
  end

  # POST /product_related_products
  def create
    @product_related_product = ProductRelatedProduct.new(product_related_product_params)

    if @product_related_product.save
      redirect_to @product_related_product, notice: 'Product related product was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /product_related_products/1
  def update
    if @product_related_product.update(product_related_product_params)
      redirect_to @product_related_product, notice: 'Product related product was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /product_related_products/1
  def destroy
    @product_related_product.destroy
    respond_to do |format|
      format.html { head :ok, notice: 'Product related product was successfully destroyed.' }
      format.json { head :ok }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_product_related_product
      @product_related_product = ProductRelatedProduct.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def product_related_product_params
      params.require(:product_related_product).permit(:product_id, :related_prooduct)
    end
end
