class Item < ApplicationRecord
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  belongs_to :merchant
  validates :name, :description, :unit_price, :merchant_id, presence: true

  class << self
    def search(query)
      where('name ilike ?', "%#{query}%")
    end

    def most_revenue(num = 10)
      joins(invoices: :transactions)
        .select('items.*, sum(invoice_items.quantity * invoice_items.unit_price) as revenue')
        .where('invoices.status =?', 'shipped')
        .where('transactions.result = ?', 'success')
        .group(:id)
        .order('revenue' => :desc)
        .limit(num)
    end
  end
end
