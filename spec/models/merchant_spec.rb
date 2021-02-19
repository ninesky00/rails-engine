require "rails_helper"

RSpec.describe Merchant, type: :model do
  describe "relations" do
    it {should have_many :invoices}
    it {should have_many :items}
    it {should have_many(:customers).through(:invoices)}
  end

  describe "class methods" do 
    it "search" do 
      merchant = create(:merchant, name: 'feafasdfaefgaef')
      distracting_merchant = create(:merchant, name: 'lululalahahaeafeefeafree')
      expect(Merchant.search('fae')).to eq(merchant)
    end

    it "top revenue" do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      merchant3 = create(:merchant)
      item1 = create(:item, merchant: merchant1, unit_price: 100)
      item2 = create(:item, merchant: merchant2, unit_price: 90)
      item3 = create(:item, merchant: merchant3, unit_price: 80)
      invoice1 = create(:invoice, merchant: merchant1, status: 'shipped', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant2, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant3, status: 'shipped', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 1, unit_price: 100)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 1, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 1, unit_price: 80)

      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')

      expect(Merchant.top_revenue(2)).to include(merchant1)
      expect(Merchant.top_revenue(2)).to include(merchant2)
      expect(Merchant.top_revenue(2)).to_not include(merchant3)
    end

    it "most_items_sold" do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      merchant3 = create(:merchant)
      item1 = create(:item, merchant: merchant1, unit_price: 100)
      item2 = create(:item, merchant: merchant2, unit_price: 90)
      item3 = create(:item, merchant: merchant3, unit_price: 80)
      invoice1 = create(:invoice, merchant: merchant1, status: 'shipped', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant2, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant3, status: 'shipped', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 80, unit_price: 100)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 90, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 100, unit_price: 80)
  
      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')

      expect(Merchant.most_items_sold(2)).to include(merchant3)
      expect(Merchant.most_items_sold(2)).to include(merchant2)
      expect(Merchant.most_items_sold(2)).to_not include(merchant1)
    end

    it "period_revenue" do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      merchant3 = create(:merchant)
      item1 = create(:item, merchant: merchant1, unit_price: 100)
      item2 = create(:item, merchant: merchant2, unit_price: 90)
      item3 = create(:item, merchant: merchant3, unit_price: 80)
      invoice1 = create(:invoice, merchant: merchant1, status: 'shipped', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant2, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant3, status: 'shipped', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 80, unit_price: 100)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 90, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 100, unit_price: 80)

      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')
      
      start_date, end_date = '2012-02-20', '2012-03-15'

      expect(Merchant.period_revenue(start_date, end_date)).to eq(90*90 + 100*80)
    end

    it "revenue" do 
      merchant1 = create(:merchant)
      merchant2 = create(:merchant)
      item1 = create(:item, merchant: merchant1, unit_price: 100)
      item2 = create(:item, merchant: merchant1, unit_price: 90)
      item3 = create(:item, merchant: merchant2, unit_price: 80)
      invoice1 = create(:invoice, merchant: merchant1, status: 'shipped', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant1, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant2, status: 'shipped', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 80, unit_price: 100)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 90, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 100, unit_price: 80)

      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')

      expect(Merchant.revenue(merchant1.id)).to eq(80*100 + 90*90)
      expect(Merchant.revenue(merchant2.id)).to eq(100* 80)
    end
  end
end