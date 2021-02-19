class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.paginate(params[:per_page], params[:page]))
  end

  def show
    if Merchant.exists?(params[:id])
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    else
      render json: { error: "No merchant ID #{params[:id]}" }, status: :not_found
    end
  end

  def find
    if Merchant.search(params[:name]) && params[:name].length >= 3
      render json: MerchantSerializer.new(Merchant.search(params[:name]))
    else
      render json: { data: {} }, status: :bad_request
    end
  end

  def most_items
    if params[:quantity] && params[:quantity].to_i.positive?
      render json: MerchantNameItemSerializer.new(Merchant.most_items_sold(params[:quantity]))
    else
      render json: { error: {} }, status: :bad_request
    end
  end
end
