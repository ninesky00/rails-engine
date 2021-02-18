class Api::V1::RevenueController < ApplicationController
  def merchants
    if params[:quantity] && params[:quantity].to_i > 0
      render json: MerchantNameRevenueSerializer.new(Merchant.top_revenue(params[:quantity]))
    else
      render json: { error: {}}, status: 400
    end
  end
end