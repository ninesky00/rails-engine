class Api::V1::MerchantsController < ApplicationController
  def index
    paginate render json: MerchantSerializer.new(Merchant.all), per_page: 20
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def create
    Merchant.create(merchant_params)
  end

  def update
    Merchant.update(params[:id], merchant_params)
  end

  def destroy
    Merchant.destroy(params[:id])
  end

  private 

  def merchant_params
    params.require(:merchant).permit(:name)
  end

end