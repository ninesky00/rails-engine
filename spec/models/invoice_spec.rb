require "rails_helper"

RSpec.describe Invoice, type: :model do
  describe "relations" do
    it {should belong_to :customer}
    it {should belong_to(:merchant).optional}
    it {should have_many :transactions}

    it {should have_many :invoice_items}
    it {should have_many :items}
  end

  describe "class methods" do 
    it "unshipped_invoices" do 
      merchant1 = create(:merchant)
      merchant3 = create(:merchant)
      item1 = create(:item, merchant: merchant1, unit_price: 80)
      item2 = create(:item, merchant: merchant1, unit_price: 90)
      item3 = create(:item, merchant: merchant3, unit_price: 100)
      invoice1 = create(:invoice, merchant: merchant1, status: 'packaged', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant1, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant3, status: 'packaged', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 1, unit_price: 80)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 1, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 1, unit_price: 100)
  
      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')

      expect(Invoice.unshipped_invoices(2)).to include(invoice1)
      expect(Invoice.unshipped_invoices(2)).to include(invoice3)
      expect(Invoice.unshipped_invoices(2)).to_not include(invoice2)
    end
  end
end