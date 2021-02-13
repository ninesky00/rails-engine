class Api::V1::MerchantsController < ApplicationController
  def index
    merchants = Merchant.all
    render json: MerchantsSerializer.format_merchants(merchants)
  end

  def show
    merchant = Merchant.find(params[:id])
    render json: MerchantsSerializer.single_merchant(merchant)
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