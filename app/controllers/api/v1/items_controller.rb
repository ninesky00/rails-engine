class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.paginate(params[:per_page], params[:page]))
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    render json: Item.create(item_params)
  end

  def update
    render json: Item.update(params[:id], item_params)
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  private 

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end

end