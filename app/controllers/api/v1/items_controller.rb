class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.paginate(params[:per_page], params[:page]))
  end

  def show
    if Item.exists?(params[:id])
      render json: ItemSerializer.new(Item.find(params[:id]))
    else
      render json: { error: "No merchant ID #{params[:id]}"}, status: 404
    end
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: 201
    else
      render json: { data: item.errors}, status: 409
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item), status: 202
    else
      render json: { data: item.errors}, status: 404
    end
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  private 

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

end