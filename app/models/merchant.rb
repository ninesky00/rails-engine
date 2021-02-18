class Merchant < ApplicationRecord
  has_many :items
  has_many :invoices
  has_many :customers,-> {distinct}, through: :invoices

  def self.search(query)
    where('name ilike ?', "%#{query}%").first
  end
end