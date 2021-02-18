class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.paginate(params[:per_page], params[:page]))
  end

  def show
    if Merchant.exists?(params[:id])
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    else
      render json: { error: "No merchant ID #{params[:id]}"}, status: 404
    end
  end

  def find
    if params[:name] && params[:name].length >= 3
      render json: MerchantSerializer.new(Merchant.search(params[:name]))
    else
      render json: { data: {}}
    end
  end

  def most_revenue
    if params[:quantity]
      render json: MerchantSerializer.new(Merchant.top_merchants_by_revenue(params[:quantity]))
    else
      render json: { data: {}}
    end
  end
end