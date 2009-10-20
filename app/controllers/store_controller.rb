class StoreController < ApplicationController
  def index
    @products = Product.find_products_for_sale
    
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @products }
    end
  end
    
  def add_to_cart
    product = Product.find(params[:id])
    @cart=find_cart
    @cart.add_product(product)
  rescue ActiveRecord::RecordNotFound
    logger.error("Attempt to access invalid product #{params[:id]}")
    flash[:notice]="Invalid Product"
    redirect_to :action => 'index'
  end
  
  def empty_cart
    session[:cart] = nil
    flash[:notice] = "Your cart is currently empty"
    redirect_to :action => 'index'
  end

  private
  def find_cart
    session[:cart] ||=Cart.new
  end
end
