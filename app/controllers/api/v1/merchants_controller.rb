class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.paginate(params[:per_page], params[:page]))
  end

  def show
    render json: MerchantSerializer.new(Merchant.find(params[:id]))
  end

  def create
    render json: Merchant.create(merchant_params)
  end

  def update
    render json: Merchant.update(params[:id], merchant_params)
  end

  def destroy
    render json: Merchant.destroy(params[:id])
  end

  private 

  def merchant_params
    params.require(:merchant).permit(:name)
  end

end