class Invoice < ApplicationRecord
  scope :incomplete, -> { where(status: "packaged")}
  scope :period, -> (start, ending) { 
    where("invoices.updated_at >= ? AND invoices.updated_at <= ?", start, ending)
  }
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :transactions
  belongs_to :customer
  belongs_to :merchant, optional: true

  class << self
    def unshipped_invoices(num = 10)
      joins(:transactions, :invoice_items)
      .select('invoices.*, sum(quantity * unit_price) as potential_revenue')
      .where('invoices.status =?', "packaged")
      .where('transactions.result = ?', "success")
      .group(:id)
      .order('potential_revenue' => :desc)
      .limit(num)
    end
  end
end