class Api::V1::ItemsController < ApplicationController
  def index
    if params[:per_page].to_i < 0 || params[:page].to_i < 0
      render json: {error: 'bad search query'}, status: :bad_request
    else
      render json: ItemSerializer.new(Item.paginate(params[:per_page], params[:page]))
    end
  end

  def show
    if Item.exists?(params[:id])
      render json: ItemSerializer.new(Item.find(params[:id]))
    else
      render json: { error: "No merchant ID #{params[:id]}" }, status: :not_found
    end
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(item), status: :created
    else
      render json: { data: item.errors }, status: :conflict
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params)
      render json: ItemSerializer.new(item), status: :accepted
    else
      render json: { data: item.errors }, status: :not_found
    end
  end

  def destroy
    render json: Item.destroy(params[:id])
  end

  def find_all
    if params[:name] && params[:name].length >= 3
      render json: ItemSerializer.new(Item.search(params[:name]))
    else
      render json: { data: [] }, status: :bad_request
    end
  end

  private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
