class Api::V1::Merchants::ItemsController < ApplicationController
  def index
    if Merchant.exists?(params[:id])
      merchant = Merchant.find(params[:id])
      render json: ItemSerializer.new(merchant.items)
    else
      render json: { error: "No merchant ID #{params[:id]}"}, status: 404
    end
  end
end