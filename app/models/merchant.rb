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
      .merge(Invoice.complete)
      .merge(Transaction.success)
      .group(:id)
      .order('revenue' => :desc)
      .limit(num)
    end

    def most_items_sold(num = 5)
      joins(invoices: [:transactions, :invoice_items])
      .select('merchants.*, sum(quantity) as count')
      .merge(Invoice.complete)
      .merge(Transaction.success)
      .order('count' => :desc)
      .group(:id)
      .limit(num)
    end

    def period_revenue(start_date, end_date)
      joins(invoices: [:transactions, :invoice_items])
      .merge(Invoice.complete)
      .merge(Transaction.success)
      .merge(Invoice.period(Date.parse(start_date).beginning_of_day, Date.parse(end_date).end_of_day))
      .sum('quantity * unit_price')
    end
  end
end