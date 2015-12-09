class CartController < ApplicationController
  
  # PUT /coupons/1
  # PUT /coupons/1.json
  def update
    @cart=Cart.get_cart("cart"+session[:session_id], session[:user_id]) rescue  Rails.cache.write("cart"+session[:session_id],{}, :expires_in => 15.minutes)
   puts("params[:cart]:#{params[:cart]} , params[params[:cart]]: #{params[params[:cart]]} , params[:cart][params[:cart]]: #{params[:cart][params[:cart]]}")

    @cart.send(params[:cart].keys.first + "=", params[:cart].values.first.to_i)
    
    @cart.save
    
    respond_to do |format|
      format.html { redirect_to @cart, notice: "Cart was successfully updated."}
      format.json { head :ok }
    end
  end
  
end