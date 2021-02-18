class Item < ApplicationRecord
  has_many :invoice_items
  has_many :invoices, through: :invoice_items
  belongs_to :merchant

  def self.search(query)
    where('name ilike ?', "%#{query}%")
  end

  def self.search_description(query)
    where('description ilike ?', "%#{query}%")
  end
end