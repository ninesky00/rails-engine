class Api::V1::RevenueController < ApplicationController
  def merchants
    if params[:quantity] && params[:quantity].to_i > 0
      render json: MerchantNameRevenueSerializer.new(Merchant.top_revenue(params[:quantity]))
    else
      render json: { error: {}}, status: 400
    end
  end

  def revenue_period
    if params[:start].present? && params[:end].present?
      render json: RevenueSerializer.period(Merchant.period_revenue(params[:start], params[:end]))
    else 
      render json: { error: 'Invalid Search'}, status: 400
    end
  end

  def items
    if params[:quantity] && params[:quantity].to_i > 0
      render json: ItemRevenueSerializer.new(Item.most_revenue(params[:quantity]))
    else 
      render json: { error: {}}, status: 400
    end
  end

  def unshipped
    return render json: { error: {}}, status: 400 if params[:quantity].to_i < 1
    render json: RevenueSerializer.unshipped_order(Invoice.unshipped_invoices(params[:quantity]))
  end
end