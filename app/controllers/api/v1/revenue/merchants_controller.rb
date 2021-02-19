class Api::V1::Revenue::MerchantsController < ApplicationController
  def show
    if Merchant.exists?(params[:id])
      render json: MerchantRevenueSerializer.format(Merchant.find(params[:id]))
    else
      render json: { error: "No merchant ID #{params[:id]}" }, status: :not_found
    end
  end
end
