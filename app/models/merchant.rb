class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :customers,-> {distinct}, through: :invoices

  def self.search(query)
    where('name ilike ?', "%#{query}%").first
  end

  def self.top_merchants_by_revenue(num)
    joins(invoices: [:invoice_items])
    .group(:id)
    .select('merchants.*, sum(quantity * unit_price) as total_revenue')
    .order('total_revenue' => :desc)
    .limit(num)
  end
end