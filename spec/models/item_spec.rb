require "rails_helper"

describe Item, type: :model do
  describe "relations" do
    it {should have_many :invoice_items}
    it {should have_many(:invoices).through(:invoice_items)}
    it {should belong_to :merchant}
  end

  describe "validations" do 
    it { should validate_presence_of(:name)}
    it { should validate_presence_of(:description)}
    it { should validate_presence_of(:unit_price)}
    it { should validate_presence_of(:merchant_id)}
  end

  describe "class methods" do 
    it "search" do 
      item = create(:item, name: 'ReAllY HarD To FiND')
      query = 'hard'
      expect(Item.search(query)).to include(item)
    end

    it "most_revenue" do 
      merchant = create(:merchant)
      item1 = create(:item, merchant: merchant, unit_price: 80)
      item2 = create(:item, merchant: merchant, unit_price: 90)
      item3 = create(:item, merchant: merchant, unit_price: 100)
      invoice1 = create(:invoice, merchant: merchant, status: 'shipped', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant, status: 'shipped', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 1, unit_price: 80)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 1, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 1, unit_price: 100)
  
      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')

      expect(Item.most_revenue(2)).to include(item3)
      expect(Item.most_revenue(2)).to include(item2)
      expect(Item.most_revenue(2)).to_not include(item1)
    end
  end
end