class Item < ApplicationRecord
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  belongs_to :merchant

  class << self
    def search(query)
      where('name ilike ?', "%#{query}%")
    end

    def search_description(query)
      where('description ilike ?', "%#{query}%")
    end

    def most_revenue(num = 10)
      joins(invoices: :transactions)
      .select('items.*, sum(invoice_items.quantity * invoice_items.unit_price) as revenue')
      .merge(Invoice.complete)
      .merge(Transaction.success)
      .group(:id)
      .order('revenue' => :desc)
      .limit(num)
    end
  end
end