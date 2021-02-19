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

  def find_all
    if params[:name] && params[:name].length >= 3
      render json: ItemSerializer.new(Item.search(params[:name]))
    elsif params[:description]
      render json: ItemSerializer.new(Item.search_description(params[:description]))
    else
      render json: { data: []}, status: 400
    end
  end

  # def revenue
  #   if params[:quantity].present? && params[:quantity].to_i > 0
  #     render json: ItemRevenueSerializer.new(Item.most_revenue(params[:quantity]))
  #   else 
  #     render json: { error: 'Invalid search'}, status: 400
  #   end
  # end

  private 

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end