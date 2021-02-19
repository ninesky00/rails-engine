require 'rails_helper'

RSpec.describe "Revenue API" do
  describe "merchant end points happy path" do 
    it "can find total revenue for a single merchant" do 
      merchant = create(:merchant)
      item1 = create(:item, merchant: merchant, unit_price: 100)
      item2 = create(:item, merchant: merchant, unit_price: 90)
      item3 = create(:item, merchant: merchant, unit_price: 80)
      invoice1 = create(:invoice, merchant: merchant, status: 'shipped', updated_at: '1990-02-20')
      invoice2 = create(:invoice, merchant: merchant, status: 'shipped', updated_at: '2012-02-20')
      invoice3 = create(:invoice, merchant: merchant, status: 'shipped', updated_at: '2012-03-15')
      create(:invoice_item, item: item1, invoice: invoice1, quantity: 80, unit_price: 100)
      create(:invoice_item, item: item2, invoice: invoice2, quantity: 90, unit_price: 90)
      create(:invoice_item, item: item3, invoice: invoice3, quantity: 100, unit_price: 80)

      transaction = create(:transaction, invoice: invoice1, result: 'success')
      transaction = create(:transaction, invoice: invoice2, result: 'success')
      transaction = create(:transaction, invoice: invoice3, result: 'success')

      get "/api/v1/revenue/merchants/#{merchant.id}"

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      data = data[:data]
      expect(data[:type]).to eq("merchant_revenue")
      expect(data[:id]).to eq(merchant.id.to_s)
      expect(data[:attributes]).to have_key(:revenue)
      expect(data[:attributes][:revenue].to_f).to eq(((80 * 100) + (90 * 90) + (100 * 80)).to_f)
    end

    it "find total revenue across all merchants given date range" do 
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

      get "/api/v1/revenue?start=2012-02-20&end=2012-03-15"

      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      revenue = data[:data]
      expect(revenue[:type]).to eq("revenue")
      expect(revenue[:id]).to be_nil
      expect(revenue[:attributes]).to have_key(:revenue)
      expect(revenue[:attributes][:revenue].to_f).to eq(((90 * 90) + (100 * 80)).to_f)
    end

    it "find merchants ranked by total revenue" do
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

      get "/api/v1/revenue/merchants?quantity=2"
      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      data1, data2 = data[:data][0], data[:data][1]

      expect(data1[:type]).to eq("merchant_name_revenue")
      expect(data1[:id]).to eq(merchant1.id.to_s)
      expect(data1[:attributes][:name]).to eq(merchant1.name)
      expect(data1[:attributes]).to have_key(:revenue)

      expect(data2[:type]).to eq("merchant_name_revenue")
      expect(data2[:id]).to eq(merchant2.id.to_s)
      expect(data2[:attributes][:name]).to eq(merchant2.name)
      expect(data2[:attributes]).to have_key(:revenue)
    end
  end

  describe "item end points happy path" do 
    it "can find items ranked by revenue" do 
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
  
      get "/api/v1/revenue/items?quantity=2"
      expect(response.status).to eq(200)
      data = JSON.parse(response.body, symbolize_names: true)
      data1, data2 = data[:data][0], data[:data][1]
  
      expect(data1[:type]).to eq("item_revenue")
      expect(data1[:id]).to eq(item3.id.to_s)
      expect(data1[:attributes][:name]).to eq(item3.name)
      expect(data1[:attributes][:description]).to eq(item3.description)
      expect(data1[:attributes][:unit_price]).to eq(item3.unit_price)
      expect(data1[:attributes][:merchant_id]).to eq(merchant.id)
      expect(data1[:attributes]).to have_key(:revenue)
  
      expect(data2[:type]).to eq("item_revenue")
      expect(data2[:id]).to eq(item2.id.to_s)
      expect(data2[:attributes][:name]).to eq(item2.name)
      expect(data2[:attributes][:description]).to eq(item2.description)
      expect(data2[:attributes][:unit_price]).to eq(item2.unit_price)
      expect(data2[:attributes][:merchant_id]).to eq(merchant.id)
      expect(data2[:attributes]).to have_key(:revenue)
    end
  end

  it "can find potential revenue of unshipped orders, ranked by invoices' potential revenue" do 
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

    get '/api/v1/revenue/unshipped?quantity=2'
    
    data = JSON.parse(response.body, symbolize_names: true)
    data1, data2 = data[:data][0], data[:data][1]
    
    expect(data1[:type]).to eq("unshipped_order")
    expect(data1[:id]).to eq(invoice3.id.to_s)
    expect(data1[:attributes][:potential_revenue].to_f).to eq(100.to_f)

    expect(data2[:type]).to eq("unshipped_order")
    expect(data2[:id]).to eq(invoice1.id.to_s)
    expect(data2[:attributes][:potential_revenue].to_f).to eq(80.to_f)
  end
  
  describe "merchant end points sad path" do 
    it "will error to find total revenue for a merchant if merchant not in database" do 
      merchant = create(:merchant)

      get "/api/v1/revenue/merchants/bad_id"
      expect(response.status).to eq(404)
      get "/api/v1/revenue/merchants/404"
      expect(response.status).to eq(404)
    end

    it "will error to find total revenue across all merchants if dates are wrong" do 
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

      get "/api/v1/revenue?start_date=2100-01-01&end_date=2000-01-01"
      expect(response.status).to eq(400)
      get "/api/v1/revenue?start_date=2100-01-01"
      expect(response.status).to eq(400)
      get "/api/v1/revenue"
      expect(response.status).to eq(400)
      get "/api/v1/revenue?end_date=2000-01-01"
      expect(response.status).to eq(400)
    end

    it "will error to find merchants ranked by total revenue without quantity" do
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

      get "/api/v1/revenue/merchants?quantity="
      expect(response.status).to eq(400)
      get "/api/v1/revenue/merchants"
      expect(response.status).to eq(400)
      get '/api/v1/revenue/merchants?quantity=asdasd'
      expect(response.status).to eq(400)
    end
  end

  describe "item end points sad path" do 
    it "will error can find items ranked by revenue if search is incorrect" do 
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
  
      get "/api/v1/revenue/items?quantity="
      expect(response.status).to eq(400)
      get "/api/v1/revenue/items"
      expect(response.status).to eq(400)
      get "/api/v1/revenue/items?quantity=asdasd"
      expect(response.status).to eq(400)
    end
  end

  it " unshipped orders sad path" do 
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

    get '/api/v1/revenue/unshipped?quantity='
    expect(response.status).to eq(400)
    get '/api/v1/revenue/unshipped?quantity=-6'
    expect(response.status).to eq(400)

  end
end