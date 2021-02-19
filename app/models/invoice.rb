class Invoice < ApplicationRecord
  scope :complete, -> { where(status: "shipped")}
  scope :period, -> (start, ending) { 
    where("invoices.updated_at >= ? AND invoices.updated_at <= ?", start, ending)
  }
  has_many :invoice_items
  has_many :items, through: :invoice_items
  has_many :transactions
  belongs_to :customer
  belongs_to :merchant, optional: true
end