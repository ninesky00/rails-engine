class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :customers,-> {distinct}, through: :invoices
  
  class << self 
    def search(query)
      where('name ilike ?', "%#{query}%").first
    end

    def top_revenue(num = 5)
      joins(invoices: [:transactions, :invoice_items])
      .select('merchants.*, sum(quantity * unit_price) as revenue')
      .merge(Transaction.success)
      .group(:id)
      .order('revenue' => :desc)
      .limit(num)
    end

    def most_items_sold(num = 5)
      joins(invoices: [:transactions, :invoice_items])
      .select('merchants.*, sum(quantity) as count')
      .merge(Transaction.success)
      .order('count' => :desc)
      .group(:id)
      .limit(num)
    end
  end
end