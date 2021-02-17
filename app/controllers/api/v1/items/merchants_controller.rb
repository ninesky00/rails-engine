class Api::V1::Items::MerchantsController < ApplicationController
  def show
    if Item.exists?(params[:id])
      item = Item.find(params[:id])
      render json: MerchantSerializer.new(item.merchant)
    else
      render json: { error: "No item ID #{params[:id]}"}, status: 404
    end
  end
end