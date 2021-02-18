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

  def most_items
    if params[:quantity] && params[:quantity].to_i > 0
      render json: MerchantNameItemSerializer.new(Merchant.most_items_sold(params[:quantity]))
    else
      render json: { error: {}}, status: 400
    end
  end
end